from crypt import methods
from flask import Flask, render_template, request
import subprocess
import os
import json
import yaml

app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return render_template("index.html")


# Execute a dbt command
@app.route("/test", methods=["GET", "POST"])
def test():

    #TODO remove the environment variables
    os.environ["DBT_PROJECT_DIR"]="dbt_process"
    os.environ["DBT_PROFILES_DIR"]="profiles"

    
    command = ["dbt"]
    arguments = []
    # Convert the request data bytes object to json object
    request_data = json.loads(request.data.decode("utf-8"))

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
        project_dir = os.environ.get("DBT_PROJECT_DIR", None)
        if project_dir:
            command.extend(["--project-dir", project_dir])

    if not any("--profile-dir" in c for c in command):
        profiles_dir = os.environ.get("DBT_PROFILES_DIR", None)
        if profiles_dir:
            command.extend(["--profiles-dir", profiles_dir])
    # Execute the dbt command
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

    return response, 200

@app.route("/directories", methods=["GET"])
def directories():
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