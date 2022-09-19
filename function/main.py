import json
from google.cloud import bigquery
import os
from tools import Directory, Table, Query
import requests
import base64


def pubsub_trigger(event, context):
    PROJECT_ID = os.getenv('PROJECT_ID')
    CLOUD_RUN_ENDPOINT = os.getenv('CLOUD_RUN_ENDPOINT')


    # initialize BigQuery Client
    bigquery_client = bigquery.Client(PROJECT_ID)


    directory = Directory(bigquery_client,PROJECT_ID, "dev")
    table = Table(bigquery_client, directory, "my_first_dbt_model")
    table.check_if_exist()

    request = base64.b64decode(event['data']).decode('utf-8')
    try: 
        request_json = json.loads(request)
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return "JSON Error", 400

    url = request_json.get("url")
    cli = request_json.get("cli")
    project_dir = request_json.get("--project-dir")
    profiles_dir = request_json.get("--profiles-dir")
    headers = {}

    msg = {
        "cli": cli,
        "--profiles-dir": profiles_dir,
        "--project-dir": project_dir
    }

    print(msg)
    data = json.dumps(msg)
    res = requests.post(url, data=data, headers=headers)

    return res
