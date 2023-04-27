FROM python:3.9.16-alpine

RUN apk update && apk add bash

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

ENTRYPOINT ["python", "app.py"]