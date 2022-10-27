terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.89.0"
    }
  }
}

provider "google" {
  project = "helloworld4522"
  region = "asia-southeast1"
  zone = "asia-southeast1-b"
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "vm_instance" {
  name = "terraform-instance"
  machine_type = "f1-micro"
  allow_stopping_for_update = false

  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
    }
  }

  network_interface {
    # network = google_compute_network.vpc_tr_network.self_link
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = "${file("./startup.sh")}"
}

resource "google_compute_network" "vpc_tr_network" {
  name = "terraform-network"
  auto_create_subnetworks = "true"  
}

resource "google_compute_firewall" "ssh-rule" {
  name = "allow-ssh"
  network = google_compute_network.vpc_tr_network.self_link
  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  #target_tags = ["terraform-instace"]
  source_ranges = ["0.0.0.0/0"]
}


# provisioner "env" {
#   source = "./.env"
#   destination = "/home/nguyenbt456/.env"
  
#   connection {
#     type = "ssh"
#     user = "nguyenbt456"
#     private_key = "${file("$HOME/.ssh/")}"
#     agent = false
#   }
# }