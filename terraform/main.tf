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
