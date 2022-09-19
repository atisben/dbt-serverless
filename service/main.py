from flask import Flask, render_template, request
import subprocess
import os


app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return render_template("index.html")


# Execute a dbt command
@app.route("/test", methods=["GET", "POST"])
def run():
    command = ["dbt"]
    arguments = []
    request_data = request.data

    if request_data:
        if "cli" in request_data.get("params", {}):
            arguments = request_data["params"]["cli"].split(" ")
            command.extend(arguments)

    arguments = "run".split(" ")
    command.extend(arguments)
    # Add an argument for the project dir if not specified
    if not any("--project-dir" in c for c in command):
        project_dir = os.environ.get("DBT_PROJECT_DIR", None)
        if project_dir:
            command.extend(["--project-dir", project_dir])

    if not any("--profile-dir" in c for c in command):
        profiles_dir = os.environ.get("DBT_PROFILEs_DIR", None)
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