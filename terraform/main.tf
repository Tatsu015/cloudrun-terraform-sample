terraform {
  required_version = "1.14.0"
}

provider "google" {
  credentials = file(var.key_file_path)
  project     = var.project_id
  region      = var.region
}

resource "google_artifact_registry_repository" "cloudrun-terraform-sample" {
  location      = var.region
  repository_id = var.project_name
  description   = "sample repository"
  format        = "Docker"
}

resource "google_cloud_run_v2_service" "service" {
  name                = var.project_name
  location            = var.region
  deletion_protection = var.deletion_protection
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
  lifecycle {
    ignore_changes = [
      # ignore because container updated by CI/CD gcloud command.
      template[0].containers[0].image
    ]
  }
}

resource "google_cloud_scheduler_job" "job" {
  name             = var.project_name
  schedule         = "0 0 * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "60s"

  http_target {
    http_method = "POST"
    uri         = "https://example.com/" # todo change to cloudrun URL
    body        = base64encode("{}")
    headers = {
      "Content-Type" = "application/json"
    }
  }
}
