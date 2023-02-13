# dbt-serverless processing service

dbt serverless service is a template repository for deploying scheduled serverless dbt framework based processing on GCP infrastructure

```

    .______.    __                                                   .__                        
  __| _/\_ |___/  |_            ______ ______________  __ ___________|  |   ____   ______ ______
 / __ |  | __ \   __\  ______  /  ___// __ \_  __ \  \/ // __ \_  __ \  | _/ __ \ /  ___//  ___/
/ /_/ |  | \_\ \  |   /_____/  \___ \\  ___/|  | \/\   /\  ___/|  | \/  |_\  ___/ \___ \ \___ \ 
\____ |  |___  /__|           /____  >\___  >__|    \_/  \___  >__|  |____/\___  >____  >____  >
     \/      \/                    \/     \/                 \/                \/     \/     \/
                                                                      
```

## Architecture
![Architecure](./docs/architecture.png)

# Deployement

## dbt project upload
1. Upload your dbt project folder into the `service/dbt_process` directory
2. Upload your dbt profiles.yml file into the `service/profiles`, make sure the project is refered as dbt_process

## Google cloud authentication

Run the following command to connect to GCP. If you are running the command on a local machine, make sure you've installed the [google cloud CLI](https://cloud.google.com/sdk/docs/install)

```sh
    gcloud auth application-default login
    gcloud auth login
```

Follow the instructions and login to your GCP project


## Cloud build push docker image

Cloud Build is used to push the docker image in Google Container Registry.
Run the following command to push the docker image to gcr

```sh
gcloud builds submit --project <my_project>
```

## Set up Google cloud services using terraform
Terraform is used to create the Cloud Run service (sourcing from Container Registry), Cloud Storage, and Cloud Functions. IAM is configured throughout the automation.

```
terraform init
terraform plan
terraform apply
```


# WIP Copy the content of the models to the google cloud storage bucket

# Using variables 

dbt variables can be set before the run to replace any available placeholder in the dbt models `{{var("my_var")}}`

## Setting up variables from cloud scheduler
Variables set through the Cloud scheduler are easily accessed and modified from the cloud scheduler payload. This option is recommended when the variables don't rely on any external dependency.

varialbes must be defined as a dictionnary of "key" : "values" pairs under the `"--vars"` parameter of the scheduler payload
*note that every default python methods as well as datetime.date and datetime.timedelta can be used to define a variable*

e.g.
```json
"--vars": {
    "start_date":"date.today()",
    "name": "Frank"
    "number": "round(0.0239)"
    }
```

## Setting up variables from the Cloud function
Variables set through the cloud function are made to be generated from an external dependency (e.g. retrieve the latest date of a BigQuery column)
To add a var value generated from the cloud function, simply update the `--vars` dictionnary within the metadata.


# Local debugging
## Run docker as command line

```sh
docker run -it --entrypoint /bin/bash <image_name>
```

## Service
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

### Run dbt


Make sure you are located in the `service/dbt_process/` directory
Run dbt test localy (adapt the example below)
```sh
dbt test \
--vars '{"day_before_yesterday": "20221104", "first_day_of_month": "20221101", "start_year_month": "2022_11", "year_month": "202211", "yesterday": "20221105"}' \
--project-dir dbt_process \
--profiles-dir profiles
```
Run dbt run localy (adapt the example below)

```sh
dbt run \
--vars '{"day_before_yesterday": "20221104", "first_day_of_month": "20221101", "start_year_month": "2022_11", "year_month": "202211", "yesterday": "20221105"}' \
--project-dir dbt_process \
--profiles-dir profiles
```