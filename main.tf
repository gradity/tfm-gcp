terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"

  tags = ["tfm", "web"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      # image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}

resource "google_compute_disk" "default" {
  name  = "terraform-disk"
  type  = "pd-ssd"
  zone  = "asia-southeast2-a"
  image = "debian-9-stretch-v20200805"
  size = 20
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.name
  instance = google_compute_instance.vm_instance.name
}

resource "google_compute_firewall" "default" {
  name    = "tfm-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20", "66.96.231.26"]
}