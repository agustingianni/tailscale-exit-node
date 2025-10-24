terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable the Compute Engine API if it isn't already
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# The VM
resource "google_compute_instance" "tailscale" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  boot_disk {
    # This prevents unused (and billable) disks from being left behind.
    auto_delete = true
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-minimal-2404-lts-amd64"
      size  = 10
      type  = "pd-standard"
    }
  }

  # Configure the VM's network connection.
  network_interface {
    # Connect this VM to Google's default network so it can go online.
    network = "default"

    # Give the VM a public IP address.
    access_config {}
  }

  scheduling {
    # Restart the VM automatically if it crashes or is stopped for maintenance.
    automatic_restart = true

    # Move the VM to another host during maintenance instead of shutting it down.
    on_host_maintenance = "MIGRATE"
  }

  # Start Tailscale on first boot
  metadata = {
    startup-script = templatefile("${path.module}/startup.sh.tpl", {
      tailscale_authkey = var.tailscale_authkey
      instance_hostname = var.instance_name
    })
  }

  # Make sure the Compute Engine API is turned on before creating this VM.
  depends_on = [google_project_service.compute]
}
