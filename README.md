# 🌀 Tailscale Exit Proxy — Terraform Module

Provision a lightweight [Google Compute Engine (GCE)](https://cloud.google.com/compute) instance configured as a [Tailscale](https://tailscale.com/) **exit node** using Terraform.  
This module enables required APIs, creates the instance, and injects a startup script that automatically installs and authenticates Tailscale — advertising exit-node capability for your Tailnet.

## 🚀 Overview

This Terraform module automates setup of a GCE VM that acts as a **Tailscale Exit Proxy**, allowing your devices to route internet traffic securely through your own infrastructure.

Terraform performs the following steps:

1. Enables the Compute Engine API.
2. Provisions a VM with your chosen size, region, and zone.
3. Injects a startup script that:
   - Installs and starts Tailscale.
   - Authenticates using your Tailscale auth key.
   - Advertises itself as an **exit node**.

## 🧰 Prerequisites

Before you begin, ensure you have:

- A **Google Cloud project** with billing enabled.
- Owner or editor permissions on that project.
- The [`gcloud`](https://cloud.google.com/sdk/docs/install) CLI installed and authenticated (`gcloud auth login`)
- **Terraform 1.5+** installed.
- A **Tailscale auth key** with exit-node capability ([generate here](https://login.tailscale.com/admin/settings/keys)).

## 📁 Project Layout

| File               | Description                                                               |
| ------------------ | ------------------------------------------------------------------------- |
| `main.tf`          | Core Terraform resources: API enablement, GCE instance, metadata.         |
| `variables.tf`     | Configurable module inputs (project, region, VM size, auth key).          |
| `startup.sh.tpl`   | Template for startup script that installs & configures Tailscale.         |
| `terraform.tfvars` | Sensitive values such as the Tailscale auth key (never commit real keys). |
| `Makefile`         | Convenience commands for `init`, `plan`, `apply`, `destroy`, etc.         |

## ⚡ Quick Start

### 1. Create or select a GCP project

```bash
gcloud projects create tailscale-exit-proxy --name="Tailscale Exit Proxy" --set-as-default
gcloud beta billing accounts list
gcloud beta billing projects link tailscale-exit-proxy --billing-account=<ACCOUNT_ID>
gcloud services enable compute.googleapis.com
```

### 2. Initialize Terraform

```bash
make init
```

### 3. Configure required variables

A sample configuration file is provided in this repository as [`terraform.tfvars.example`](./terraform.tfvars.example).
Copy it to `terraform.tfvars` and edit it with your own project details and Tailscale auth key:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then open `terraform.tfvars` and update the values:

```hcl
project_id        = "tailscale-exit-proxy"
tailscale_authkey = "tskey-<your-auth-key>"
```

### 4. Review and deploy

```bash
make plan
make apply
```

### ✅ Verifying the Exit Node

After `terraform apply` completes, verify that your instance is running and that Tailscale is active:

```bash
# List the created instance
gcloud compute instances list

# Connect to the VM (replace zone or name if different)
gcloud compute ssh tailscale-free \
  --project tailscale-exit-proxy \
  --zone us-east1-b
```

Once connected **inside the VM shell**, run:

```bash
sudo tailscale status
```

You should see the node listed and connected to your Tailnet.

Finally, open the **[Tailscale Admin Console](https://login.tailscale.com/admin/machines)** and confirm:

- The new instance appears as an **exit node**.
- You can enable it for your clients via the Tailscale client UI → **Settings → Exit Node**.

## ⚙️ Configuration Reference

| Variable            | Description                    | Default          |
| ------------------- | ------------------------------ | ---------------- |
| `project_id`        | Target GCP project ID          | —                |
| `region`            | GCE region                     | `us-east1`       |
| `zone`              | GCE zone                       | `us-east1-b`     |
| `instance_name`     | VM instance name               | `tailscale-free` |
| `machine_type`      | GCE machine type               | `e2-micro`       |
| `tailscale_authkey` | Tailscale auth key (sensitive) | —                |

## 🧹 Maintenance & Cleanup

- Include `terraform plan` output in PRs to track changes before applying.

- **Rotate your Tailscale auth key** periodically or after exposure.

- To destroy the exit node:

  ```bash
  make destroy
  ```

- Clean up local plan files:

  ```bash
  make clean
  ```

## 💡 Tips

- To check configuration formatting:

  ```bash
  make fmt-check
  ```

- To automatically fix formatting:

  ```bash
  make fmt
  ```

- To validate all configurations:

  ```bash
  make validate
  ```

## 🧾 License

This project is licensed under the [Apache License 2.0](./LICENSE).

© 2025 — Maintained by [@agustingianni](https://github.com/agustingianni)
