import json
from google.cloud import bigquery
import os
from tools import Directory, Table, Query
import requests
import base64

PROJECT_ID = os.getenv('PROJECT_ID')
CLOUD_RUN_ENDPOINT = os.getenv('CLOUD_RUN_ENDPOINT')

# initialize BigQuery Client
bigquery_client = bigquery.Client(PROJECT_ID)


directory = Directory(bigquery_client,PROJECT_ID, "dev")
table = Table(bigquery_client, directory, "my_first_dbt_model")
table.check_if_exist()
request = base64.b64decode(pmessage)

def read_request(request):
    request = request.get_data()
    try: 
        request_json = json.loads(request.decode())
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return "JSON Error", 400

    url = request_json.get("url")
    cli = request_json.get("cli")
    project_dir = request_json.get("--project-dir")
    profiles_dir = request_json.get("--project-dir")

    msg = {
        "url": url,
        "cli": cli,
        "--profiles-dir": profiles_dir,
        "--project-dir": project_dir
    }

    print(msg)
    return msg

def serverless_trigger(check, url, request):

    if check:
        headers = {}
        data = json.dumps({
            "cli": "run", 
            "--profiles-dir": "test",
            "--project-dir": "test-project"
        })
        print(data)

        res = requests.post(url, data=data, headers=headers)
        return res

def run(check, url, request):
    read_request(request)


run(check=None, url=None, request=request)