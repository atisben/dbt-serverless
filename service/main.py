from crypt import methods
from flask import Flask, render_template, request
import subprocess
import os
import json
from google.auth import jwt
from datetime import date, timedelta
import yaml


def receive_authorized_get_request(request):
    """
    receive_authorized_get_request takes the "Authorization" header from a
    request, decodes it using the google-auth client library, and returns
    back the email from the header to the caller.
    """
    auth_header = request.headers.get("Authorization")
    if auth_header:

        # split the auth type and value from the header.
        auth_type, creds = auth_header.split(" ", 1)

        if auth_type.lower() == "bearer":
            claims = jwt.decode(creds, verify=False)
            print(f"Hello, {claims['email']}!\n")

        else:
            print(f"Unhandled header format ({auth_type}).\n")
    return "Hello, anonymous user.\n"

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
        
        # Replace the vars
        if "--vars" in request_data:
            vars_dict = request_data["--vars"]
            for key, value in vars_dict:
                try:
                    vars_dict[key] = str(eval(value))
                except:
                    pass

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