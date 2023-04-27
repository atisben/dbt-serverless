import argparse
from google.cloud import storage

def create_text_file():
    """
    Creates a text file with the given filename and content in the specified Google Cloud Storage bucket.

    """
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Create a text file in Google Cloud Storage')
    parser.add_argument('--bucket', required=True, help='The name of the Google Cloud Storage bucket to create the file in')
    parser.add_argument('--filename', required=True, help='The name of the file to create')
    parser.add_argument('--content', required=True, help='The content to write to the file')
    args = parser.parse_args()

    # Initialize a Cloud Storage client
    client = storage.Client()

    # Get a reference to the Cloud Storage bucket
    bucket = client.bucket(args.bucket)

    # Get a reference to the Cloud Storage file
    file = bucket.blob(args.filename)

    # Write the content to the file
    file.upload_from_string(args.content)

    print(f"Text file {args.filename} created in bucket {args.bucket}")

if __name__ == "__main__":
    create_text_file()