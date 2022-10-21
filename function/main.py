import json
from google.cloud import bigquery
import os
from tools import Directory, Table, Query
import requests
import base64
import google.auth.transport.requests
import google.oauth2.id_token
import re

def make_authorized_header(audience):
    """
    make_authorized_header makes a header for the specified HTTP endpoint
    by authenticating with the ID token obtained from the google-auth client library
    using the specified audience value.
    """

    # Cloud Functions uses your function's URL as the `audience` value
    # audience = https://project-region-projectid.cloudfunctions.net/myFunction
    # For Cloud Functions, `endpoint` and `audience` should be equal

    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, audience)

    header= {"Authorization": f"Bearer {id_token}"}

    return header


def read_pubsub_metadata(event, context):
    '''
    Decodes base64 message into json
    '''
    
    msg = base64.b64decode(event['data']).decode('utf-8')
    try: 
        pubsub_req = json.loads(msg)
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return "JSON Error", 400

    return pubsub_req

def start_check():
    '''
    Runs custom checks on bigquery tables           
    '''

    #TODO define env variables
    PROJECT_ID = os.getenv('PROJECT_ID')
    CLOUD_RUN_ENDPOINT = os.getenv('CLOUD_RUN_ENDPOINT')

    # initialize BigQuery Client
    bigquery_client = bigquery.Client(PROJECT_ID)


    directory = Directory(bigquery_client,PROJECT_ID, "dev")
    table = Table(bigquery_client, directory, "my_first_dbt_model")
    return(table.check_if_exist())


def pubsub_to_cloudrun(event, context):
    '''
    Main function triggered by PubSub message. Reads the content of the pub sub mesagge and pass it to the
    cloud function API

        Parameters:
            event (base64): PubSub message
            context* (base64): Metadata recieved by pubSub message

        Returns:
            request : Post request to the endpoint API
    
    '''

    # Read metadata from pubSub message
    metadata = read_pubsub_metadata(event, context)
    endpoint = metadata.get('endpoint')
    print(f"cloudrun endpoint: {endpoint}")
    audience_search = re.search("(.*app)", endpoint)
    if audience_search:
        audience = audience_search.group(1)
        print(f"audience: {audience}")
    else:
        raise ValueError("No valid audience founod from the specified endpoint")

    # Update vars dictionnary if required
    vars_dict = metadata["--vars"]
    print(f"metadata: {metadata}")
    
    # Build the request headers containing auth credentials
    headers = make_authorized_header(audience)

    # Send the request to pubsub
    data = json.dumps(metadata)
    req = requests.post(endpoint, data=data, headers=headers)
    print(f"request body: {req.request.body}")
    content = json.loads(req.content)
    print(json.dumps(content, indent=2))

    return req
