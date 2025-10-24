#!/usr/bin/env bash
set -euxo pipefail

# Install Tailscale using the official installer and enable the 'tailscaled' service.
curl -fsSL https://tailscale.com/install.sh | sh

# Connect this VM to your Tailnet and make it available as an exit node.
tailscale up \
  --authkey='${tailscale_authkey}' \
  --hostname='${instance_hostname}' \
  --advertise-exit-node

# Enable packet forwarding so the VM can route traffic from your Tailnet clients.
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf
