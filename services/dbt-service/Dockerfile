FROM python:3.9.16-alpine
ENV PYTHONUNBUFFERED True
ENV APP_HOME /services
ENV PORT 8080
ENV DBT_PROFILES_DIR /profiles
ENV DBT_PROJECT_DIR /project
RUN apk update && apk add bash

# Deploy the code
COPY . ${APP_HOME}
# COPY ./profiles/profiles.yml ${APP_HOME}/profiles/

# Install dependencies
WORKDIR ${APP_HOME}
RUN pip install -r requirements.txt

# Install dbt dependencies
WORKDIR ${APP_HOME}${DBT_PROJECT_DIR}
RUN dbt deps

# Start the flask service
WORKDIR ${APP_HOME}
ENTRYPOINT python -m gunicorn \
    --bind :${PORT} \
    --workers 1 \
    --threads 8 \
    --timeout 0 \
    main:app