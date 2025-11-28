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
SERVICE_ACCOUNT_KEY_FILE_NAME=${SERVICE_ACCOUNT_NAME}-key.json
GCS_BUCKET_NAME=gs://${PROJECT_ID}-tfstate


echo -e "\033[32m===================================================\033[0m"
echo -e "\033[32mfinish to create GCP resources!\033[0m"
echo ""
echo -e "\033[32mservice account secret: ./${SERVICE_ACCOUNT_KEY_FILE_NAME}\033[0m"
echo -e "\033[32m===================================================\033[0m"
