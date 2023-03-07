from flask import Flask, render_template, request
import subprocess
import os
import json
from datetime import date, timedelta
import yaml
from google.cloud import storage
import logging
import evaluate_vars


app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def home():
    response = "Please run a dbt command to display the response"
    return render_template("index.html", response=response)

@app.route("/test/app", methods=["POST"])
def test_app():
    command = []
    command.extend(request.form.get('dbt_command').split(" "))
    print("recieved requested command from the app interface")
    # Check that the command contains all the required parameters
    if not set(['dbt', '--project-dir', '--profiles-dir']).issubset(command):
        response = {"status": "wrong dbt command"}
    
    else:
        result = subprocess.run(command,
                            text=True,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
        response = {
            "result": {
                "status": "ok" if result.returncode == 0 else "error",
                "args": result.args,
                "return_code": result.returncode,
                "command_output": result.stdout,
                "command": command
            }
        }
    response = json.dumps(response, indent=4)
    return render_template("index.html", response=response)

    
# Execute a dbt command
@app.route("/run", methods=["POST"])
def test_cf():

    def download_bucket_contents(bucket_name, source_directory, destination_directory):
        storage_client = storage.Client()
        # Determine the name of the project from client object
        bucket = storage_client.bucket(f"{storage_client.project}-{bucket_name}")
        blobs = bucket.list_blobs(prefix=source_directory)  # List all objects in the bucket with the given prefix.

        for blob in blobs:
            # Extract the filename from the blob object
            relative_path = os.path.relpath(blob.name, source_directory)
            destination_path = os.path.join(destination_directory, relative_path)

            # If the object is a directory, create the local directory
            if blob.name.endswith('/'):
                os.makedirs(destination_path, exist_ok=True)
                continue

            # Download the object to a local file
            blob.download_to_filename(destination_path)

        print(f"Download complete: {source_directory} -> {destination_directory}")
        logging.info(f'Blob {source_directory} downloaded to {destination_directory}.')

    # Import the content of the models GCS bucket, models have to be .sql files
    download_bucket_contents("dbt-service", "models", "./project/models")
    # Import the content of the profiles GCS bucket, forfiles are .yml files
    download_bucket_contents("dbt-service", "profiles", "./profiles")
    # Import the content of the variables, variables are .yml files
    download_bucket_contents("dbt-service", "variables", "./variables")

    # Generate the vars folder for the project
    evaluate_vars.generate_variable_file('variables/variables.yml', 'project/vars/project_vars.yml')
    # Import the content of the variables
    download_bucket_contents("dbt-service", "tests", "./project/tests")


    request_data = json.loads(request.data.decode("utf-8"))
    print("recieved requested command from CloudFunction")

    command = ["dbt"]
    arguments = []
    
    if request_data:
        print(f"request data:{request_data}")
        if "cli" in request_data:
            arguments = request_data["cli"].split(" ")
            command.extend(arguments)
        else:
            arguments = "run".split(" ")
            command.extend(arguments)

    # Add an argument for the project dir if not specified
    if not any("--project-dir" in c for c in command):
        project_dir = "project"
        if project_dir:
            command.extend(["--project-dir", project_dir])


    if not any("--profile-dir" in c for c in command):
        profiles_dir = "profiles"
        if profiles_dir:
            command.extend(["--profiles-dir", profiles_dir])
    
    # Execute the dbt command
    print(f"Translated command: {command}")
    result = subprocess.run(command,
                            text=True,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)

# Format the response
    response = {
        "result": {
            "request_data": request_data,
            "status": "ok" if result.returncode == 0 else "error",
            "args": result.args,
            "return_code": result.returncode,
            "command_output": result.stdout,
            "command": command
        }
    }
    print(f"response: {response}")

    return render_template("index.html", response=response)

@app.route("/debug/directories", methods=["GET"])
def directories():
    '''
    Lists the directories contained in the Docker container
    
    '''
    try:
        with open("./profiles/profiles.yml", "r") as stream:
            try:
                profiles = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                profiles = exc
    except:
        profiles="Not found"

    response = {
        "directories": [x[0] for x in os.walk("./")],
        "profiles": profiles
    }
    return response, 200

if __name__ == "__main__":
    app.run(host='0.0.0.0')