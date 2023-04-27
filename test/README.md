## Build the docker image in GCR

````
docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
```


docker build -t gcr.io/datachecker-test/gcs-objcet-creator:latest .