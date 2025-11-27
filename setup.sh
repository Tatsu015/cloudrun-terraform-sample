#!/bin/bash -e

echo "setup GCP cloudrun resources."
echo "please input values"
echo "============================="

read -p "project name: " PROJECT_NAME
read -p "project id (Global unique value): " PROJECT_ID
read -p "billing account id: " BILLING_ACCOUNT
read -p "GCS region: " GCS_REGION

SERVICE_ACCOUNT_NAME="terraform-runner"
SERVICE_ACCOUNT_KEY_FILE_NAME=${SERVICE_ACCOUNT_NAME}-key.json
GCS_BUCKET_NAME=gs://${PROJECT_ID}-tfstate

echo "login to Google"

gcloud auth login
gcloud projects create ${PROJECT_ID} --name=${PROJECT_NAME}

gcloud beta billing accounts list
gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ACCOUNT}

gcloud services enable run.googleapis.com --project=${PROJECT_ID}
gcloud services enable iam.googleapis.com --project=${PROJECT_ID}

gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --display-name "${SERVICE_ACCOUNT_NAME}" --project ${PROJECT_ID}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role "roles/run.admin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role "roles/storage.admin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role "roles/iam.serviceAccountUser"

gcloud iam service-accounts keys create ${SERVICE_ACCOUNT_KEY_FILE_NAME} --iam-account ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
gcloud storage buckets create ${GCS_BUCKET_NAME} --project ${PROJECT_ID} --location ${GCS_REGION} --uniform-bucket-level-access

gcloud storage buckets add-iam-policy-binding ${GCS_BUCKET_NAME} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role "roles/storage.admin"

echo "==============================="
echo "finish to create GCP resources!"
echo "==============================="
