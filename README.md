# dbt-serverless

## Google cloud authentication

Run the following command
```sh
    gcloud auth application-default login
    gcloud auth login
```


## Cloud build commands

Cloud Build is used to create a container in Container Registry.

Run the following command to push the docker image to gcr
```sh
    gcloud builds submit . \
    --config=./services/cloudbuild.yaml \
    --project <my_project>
```

## Terraform 
Terraform is used to create the Cloud Run service (sourcing from Container Registry), Cloud Storage, and Cloud Functions. IAM is configured throughout the automation.

```
terraform init
terraform plan
terraform apply
```

## Local debugging

### Install dependencies
```sh
virtualenv .venv
source .venv/bin/activate
pip install -r service/requirements.txt
```
### Run the service locally

```sh
cd service
PORT=8081 python main.py
```