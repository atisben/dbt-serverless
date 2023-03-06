import json
from google.cloud import bigquery
import os
from tools import Directory, Table, Query
import requests
import base64
import urllib
import google.auth.transport.requests
import google.oauth2.id_token
import re
import time

def make_authorized_header(audience):
    '''
    make_authorized_header makes a header for the specified HTTP endpoint
    by authenticating with the ID token obtained from the google-auth client library
    using the specified audience value.
    '''

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

def start_check(billing_project, project, dataset, table):
    '''
    Runs custom checks on bigquery tables           
    '''

    # initialize BigQuery Client
    bigquery_client = bigquery.Client(billing_project)

    directory = Directory(bigquery_client, project, dataset)
    table = Table(bigquery_client, directory, table)
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
    for job in metadata:
        endpoint = job.get('endpoint')
        print(f"cloudrun endpoint: {endpoint}")
        audience_search = re.search("(.*app)", endpoint)
        if audience_search:
            audience = audience_search.group(1)
            print(f"audience: {audience}")
        else:
            raise ValueError("No valid audience found from the specified endpoint")

        print(f"metadata: {job}")
        
        # Build the request headers containing auth credentials
        headers = make_authorized_header(audience)

        # Send the request to pubsub
        data = json.dumps(job)
        req = requests.post(endpoint, data=data, headers=headers)
        print(f"request headers: {req.request.headers}")
        print(f"request body: {req.request.body}")
        time.sleep(60)
