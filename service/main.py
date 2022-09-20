from flask import Flask, render_template, request
import subprocess
import os
import json
from google.auth import jwt


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


def test(request):
    
    receive_authorized_get_request(request)

    #TODO remove the environment variables
    os.environ["DBT_PROJECT_DIR"]="dbt_process"
    os.environ["DBT_PROFILES_DIR"]="profiles"

    
    command = ["dbt"]
    arguments = []
    request_data = request.get_json()

    if request_data:
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
            "status": "ok" if result.returncode == 0 else "error",
            "args": result.args,
            "return_code": result.returncode,
            "command_output": result.stdout,
            "command": command
        }
    }

    return response, 200

if __name__ == "__main__":
    app.run(host='0.0.0.0')