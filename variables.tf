# Google Cloud project to use (no default on purpose).
variable "project_id" {
  type        = string
  description = "Your GCP project ID (e.g., my-project-123)."
}

# Region.
variable "region" {
  type        = string
  default     = "us-east1"
  description = "GCP region."
}

# Zone.
variable "zone" {
  type        = string
  default     = "us-east1-b"
  description = "Zone inside the region."
}

# Virtual machine name.
variable "instance_name" {
  type        = string
  default     = "tailscale-free"
  description = "Compute Engine instance name."
}

# Virtual machine type.
variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Machine type."
}

# Tailscale auth key (no default; mark sensitive).
variable "tailscale_authkey" {
  type        = string
  sensitive   = true
  description = "Tailscale auth key (from Tailscale Admin → Settings → Keys)."
}
