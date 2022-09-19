FROM python:3.10.7-slim-bullseye
ENV PYTHONUNBUFFERED True
ENV APP_HOME ./
ENV PORT 8080
ENV DBT_PROFILES_DIR ${APP_HOME}/profiles
ENV DBT_PROJECT_DIR ${APP_HOME}/dbt_process
# Deploy the code
WORKDIR ${APP_HOME}
COPY dbt_process/ ${DBT_PROJECT_DIR}/
COPY profiles/profiles.yml ${DBT_PROFILES_DIR}/
COPY static/ .
COPY templates/ .

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install dbt dependencies
WORKDIR ${DBT_PROJECT_DIR}
RUN dbt deps

# Start the flask service
WORKDIR ${APP_HOME}
COPY main.py .
ENTRYPOINT python -m gunicorn \
    --bind :${PORT} \
    --workers 1 \
    --threads 8 \
    --timeout 0 \
    main:app