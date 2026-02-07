## Model Deployment Documentation

### Steps

1. **Authenticate with Google Cloud Platform** using your credentials
  ```bash
  gcloud auth login
  ```

2. **Export the trained BigQuery ML model** to a GCS bucket
  ```bash
  bq --project_id terraform-demo-485118 extract -m zoomcamp.tip_ml_model gs://seyi-kestra-bucket/trip_models/tip_ml_model
  ```

3. **Create a local temporary directory** for model files
  ```bash
  mkdir /tmp/model
  ```

4. **Download the model from GCS** to the local directory
  ```bash
  gsutil cp -r gs://seyi-kestra-bucket/trip_models/tip_ml_model /tmp/model
  ```

5. **Create the TensorFlow Serving directory structure** with version 1
  ```bash
  mkdir -p serving_dir/tip_model/1
  ```

6. **Copy model files to the serving directory**
  ```bash
  cp -r /tmp/model/tip_ml_model/* serving_dir/tip_model/1
  ```

7. **Pull the TensorFlow Serving Docker image**
  ```bash
  docker pull tensorflow/serving
  ```

8. **Start TensorFlow Serving container** with model mounted on port 8501
  ```bash
  docker run -p 8501:8501 --mount type=bind,source=`pwd`/serving_dir/tip_model,target=/models/tip_model -e MODEL_NAME=tip_model -t tensorflow/serving &
  ```

9. **Send a prediction request** with sample trip data
  ```bash
  curl -d '{"instances": [{"passenger_count":1, "trip_distance":12.2, "PULocationID":"193", "DOLocationID":"264", "payment_type":"2","fare_amount":20.4,"tolls_amount":0.0}]}' -X POST http://localhost:8501/v1/models/tip_model:predict
  ```

10. **Verify the model** via health endpoint
   ```
   http://localhost:8501/v1/models/tip_model
   ```

[Tutorial](https://cloud.google.com/bigquery-ml/docs/export-model-tutorial)