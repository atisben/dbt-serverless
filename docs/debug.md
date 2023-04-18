# Local debugging

## Install project dependencies
```sh
virtualenv .venv
source .venv/bin/activate
pip install -r service/requirements.txt
```

## Run dbt project locally
from the following directory `services/dbt-service/`

```sh
dbt run --project-dir project --profiles-dir profiles
```

## Run docker as command line

```sh
docker run -it --entrypoint /bin/bash <image_name>
```

### Run the service locally

```sh
cd service
PORT=8081 python main.py
```

### Run dbt with custom variables

Make sure you are located in the `service/dbt-service/` directory
Run dbt test localy (adapt the example below)

```sh
dbt run \
--vars '{"my_var_1": "20221104"}' \
--project-dir project \
--profiles-dir profiles
```

```sh
cd services/dbt-service/python main.py dbt test --vars '{"my_var_1": "20221104"}' --project-dir project --profiles-dir profiles && dbt run
```