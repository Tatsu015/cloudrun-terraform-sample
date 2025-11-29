#!/bin/bash -e

echo ""
echo -e "\033[36m============================\033[0m"
echo -e "\033[36msetup GCP cloudrun resources.\033[0m"
echo -e "\033[36mplease input values\033[0m"
echo -e "\033[36m============================\033[0m"

read -p "? project name: " PROJECT_NAME
read -p "? project ID (Global unique value): " PROJECT_ID
read -p "? billing account ID: " BILLING_ACCOUNT
read -p "? GCS region: " GCS_REGION

SERVICE_ACCOUNT_NAME="terraform-runner"
SERVICE_ACCOUNT_KEY_FILE_NAME="./terraform/"${SERVICE_ACCOUNT_NAME}-key.json
GCS_BUCKET_NAME=gs://${PROJECT_ID}-tfstate

# login to GCP
gcloud auth login

# create new project
gcloud projects create ${PROJECT_ID} --name=${PROJECT_NAME}
gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ACCOUNT}

# api enablee
SERVICES=("run.googleapis.com" "iam.googleapis.com" "cloudscheduler.googleapis.com")

for service in "${SERVICES[@]}"; do
    gcloud services enable "${service}" --project="${PROJECT_ID}"
done

# create service account
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --display-name "${SERVICE_ACCOUNT_NAME}" --project ${PROJECT_ID}

# add policy
ROLES=("roles/run.admin" "roles/storage.admin" "roles/iam.serviceAccountUser" "roles/artifactregistry.admin" "roles/cloudscheduler.admin")

for role in "${ROLES[@]}"; do
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role "${role}"
done

# create key file
gcloud iam service-accounts keys create ${SERVICE_ACCOUNT_KEY_FILE_NAME} --iam-account ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

# setup GCS bucket
gcloud storage buckets create ${GCS_BUCKET_NAME} --project ${PROJECT_ID} --location ${GCS_REGION} --uniform-bucket-level-access
gcloud storage buckets add-iam-policy-binding ${GCS_BUCKET_NAME} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role "roles/storage.admin"

# display finish
echo -e "\033[32m===================================================\033[0m"
echo -e "\033[32mfinish to create GCP resources!\033[0m"
echo ""
echo -e "\033[32mservice account secret: ./${SERVICE_ACCOUNT_KEY_FILE_NAME}\033[0m"
echo ""
echo -e "next:"
echo -e "cd terraform"
echo -e "terraform plan"
echo -e "terraform apply"
echo -e "\033[32m===================================================\033[0m"
