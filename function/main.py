import json
from google.cloud import bigquery
import os
from tools import Directory, Table, Query
import requests
import base64
import google.auth.transport.requests
import google.oauth2.id_token
import urllib

def make_authorized_header(endpoint, audience):
    """
    make_authorized_header makes a header for the specified HTTP endpoint
    by authenticating with the ID token obtained from the google-auth client library
    using the specified audience value.
    """

    # Cloud Functions uses your function's URL as the `audience` value
    # audience = https://project-region-projectid.cloudfunctions.net/myFunction
    # For Cloud Functions, `endpoint` and `audience` should be equal

    req = urllib.request.Request(endpoint)
    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, audience)

    header= {"Authorization": f"Bearer {id_token}"}
    return header


def read_pubsub_metadata(event, context):
    msg = base64.b64decode(event['data']).decode('utf-8')
    try: 
        request_json = json.loads(msg)
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return "JSON Error", 400

    return request_json

def pubsub_trigger(event, context):

    #TODO define env variables
    PROJECT_ID = os.getenv('PROJECT_ID')
    CLOUD_RUN_ENDPOINT = os.getenv('CLOUD_RUN_ENDPOINT')

    # initialize BigQuery Client
    bigquery_client = bigquery.Client(PROJECT_ID)


    directory = Directory(bigquery_client,PROJECT_ID, "dev")
    table = Table(bigquery_client, directory, "my_first_dbt_model")
    table.check_if_exist()

    # Read metadata from pubSub
    metadata = read_pubsub_metadata(event, context)
    endpoint = metadata.get('endpoint')
    headers = make_authorized_header(endpoint=endpoint, audience='https://my-cloud-run-service.run.app/')

    data = json.dumps(metadata)
    req = requests.post(endpoint, data=data, headers=headers)
    print(req.request.headers)
    print(req.request.body)

    return req
