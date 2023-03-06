FROM python:3.10.7-slim-bullseye
ENV PYTHONUNBUFFERED True
ENV APP_HOME /services
ENV PORT 8080
ENV DBT_PROFILES_DIR /dbt-service/profiles
ENV DBT_PROJECT_DIR /dbt-service/project

# Deploy the code
COPY . ${APP_HOME}

# Install dependencies
WORKDIR ${APP_HOME}
RUN pip install -r requirements.txt

# Install dbt dependencies
WORKDIR ${APP_HOME}${DBT_PROJECT_DIR}
RUN dbt deps

# Start the flask service
WORKDIR ${APP_HOME}/dagster-service
EXPOSE 8080
ENTRYPOINT ["dagit", "-h", "0.0.0.0", "-p", "8080"]