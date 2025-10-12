# RKE2 Proxmox Provisioner

Automated provisioning and deployment of RKE2 Kubernetes clusters on Proxmox VE using Ansible.

## Overview

Complete automation for deploying production-ready RKE2 Kubernetes clusters on Proxmox:

1. **Provision VMs** - Clone from template, configure resources
2. **Configure Network** - Static IPs via cloud-init
3. **Deploy RKE2** - Install Kubernetes cluster
4. **Manage Lifecycle** - Create, destroy, rebuild

## Prerequisites

- **Ansible** >= 2.10
- **Task** >= 3.0 (task runner)
- **Python** >= 3.8 with `proxmoxer` and `requests` libraries
- **Proxmox VE** with API access
- **VM template** (ID: 9000) with cloud-init support

### Install Task

**macOS:**
```bash
brew install go-task
```

**Linux:**
```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
```

## Quick Start

### 1. Install Dependencies

```bash
task install
```

### 2. Configure Authentication

**Create Proxmox API Token:**
- Proxmox UI → Datacenter → Permissions → API Tokens → Add
- Save token ID and secret

**Create and configure encrypted vault:**
```bash
# Step 1: Create encrypted vault file
task vault-create
# This will:
# - Copy vault.yml.example to vault.yml
# - Open editor to enter your credentials
# - Encrypt the file with a password

# Step 2: Edit vault.yml and add your Proxmox credentials:
vault_proxmox_api_token_id: "root@pam!your-token-id"
vault_proxmox_api_token_secret: "your-secret-token"
vault_rke2_token: "your-secure-rke2-cluster-token"

# Step 3 (Optional): Save vault password to avoid repeated prompts
task vault-password-file
# Enter your vault password when prompted
```

**Manage vault later:**
```bash
# Edit encrypted vault
task vault-edit

# View vault contents
task vault-view

# Change vault password
task vault-rekey

# Debug vault (shows masked values)
task debug-vault
```

### 3. Update Configuration

**Verify settings in `group_vars/all/vars.yml`:**
- Proxmox host IP
- Node name
- SSH key paths

### 4. Deploy Cluster

```bash
task provision  # Clone and start 6 VMs
task ping      # Verify connectivity
task rke2      # Deploy Kubernetes
```

**Or all in one:**
```bash
task cluster
```

## Available Commands

```bash
# View all commands
task --list

# Setup & Installation
task install               # Install Ansible roles and collections

# Vault Management (Credential Security)
task vault-create          # Create new encrypted vault file
task vault-edit            # Edit encrypted vault credentials
task vault-view            # View vault contents (read-only)
task vault-rekey           # Change vault password
task vault-password-file   # Save vault password locally (convenience)
task vault-password-remove # Remove saved vault password
task debug-vault           # Show vault variables (masked)

# VM Lifecycle
task provision             # Clone and start VMs from template
task destroy               # Delete all VMs (with confirmation)
task verify-proxmox        # Check Proxmox connection and list templates

# Kubernetes / RKE2
task rke2                  # Deploy RKE2 cluster on provisioned VMs
task cluster               # Full deployment (install + provision + RKE2)
task rke2-check            # Dry-run RKE2 deployment

# Diagnostics & Testing
task ping                  # Test SSH connectivity to all hosts
task syntax                # Check playbook syntax
task check-inventory       # Verify inventory file
task list-hosts            # List all hosts in inventory
```

## Project Structure

```
├── Taskfile.yml                      # Task automation (30+ commands)
├── ansible.cfg                       # Ansible configuration
├── requirements.yml                  # Role & collection dependencies
├── defaults/main.yml                 # RKE2 configuration (350+ variables)
├── inventory/hosts.yml               # 6 VMs defined
├── group_vars/all/
│   ├── vars.yml                     # Proxmox & SSH settings
│   └── vault.yml                    # Encrypted API tokens
├── playbooks/
│   ├── provision-vms.yml            # Create VMs
│   ├── destroy-vms.yml              # Delete VMs
│   ├── rke2-ansible.yaml            # Deploy Kubernetes
│   └── verify-proxmox.yml           # Diagnostics
├── roles/
│   ├── lablabs.rke2/                # RKE2 deployment role
│   ├── provision-vms/               # VM cloning role
│   └── destroy-vms/                 # VM deletion role
└── docs/                             # All documentation
    ├── QUICKSTART.md
    ├── SETUP.md
    ├── TROUBLESHOOTING.md
    ├── RKE2-*.md                    # RKE2 guides
    └── *.md                         # Other docs
```

## Configuration

### Inventory (6 VMs)

**Masters:** 100-102 → 192.168.68.100-102  
**Workers:** 110-112 → 192.168.68.110-112

Edit `inventory/hosts.yml` to change IPs or add/remove nodes.

### Proxmox Settings

Edit `group_vars/all/vars.yml`:
```yaml
proxmox_host: 192.168.68.65
proxmox_node: pve-01
ssh_public_key_file: ~/.ssh/proxmox.pub
```

Edit `playbooks/provision-vms.yml`:
```yaml
proxmox_template_id: 9000  # Your template VM ID
vm_cores: 2
vm_memory: 4096
vm_storage: local
```

### Vault (Encrypted Credentials)

The encrypted vault file `group_vars/all/vault.yml` stores sensitive credentials:

```yaml
# Proxmox API authentication
vault_proxmox_api_token_id: "root@pam!your-token-id"
vault_proxmox_api_token_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# RKE2 cluster token (shared secret for nodes to join cluster)
vault_rke2_token: "your-secure-random-token-here"
```

**Create vault:**
```bash
task vault-create    # Creates and encrypts vault.yml
```

**Edit vault:**
```bash
task vault-edit      # Edit encrypted vault with your editor
```

**Vault password options:**
```bash
# Option 1: Enter password each time (more secure)
# Just use task commands, password will be prompted

# Option 2: Save password to .vault_pass file (convenience)
task vault-password-file
# Password will be auto-used by all tasks

# Remove saved password
task vault-password-remove
```

📚 **See [docs/VAULT.md](docs/VAULT.md) for complete vault management guide**

## Common Workflows

**First-time setup:**
```bash
task install        # Install dependencies
task vault-create   # Create encrypted credentials
# Edit the vault file that opens, add your tokens
# Save and exit - file will be encrypted
task verify-proxmox # Test Proxmox connection
```

**Full deployment:**
```bash
task cluster  # install + provision + RKE2 (complete automation)
```

**Step by step:**
```bash
task provision  # Clone VMs from template
task ping       # Verify SSH connectivity
task rke2       # Deploy RKE2 Kubernetes cluster
```

**Manage credentials:**
```bash
task vault-edit            # Edit encrypted credentials
task vault-view            # View vault contents
task vault-rekey           # Change vault password
task vault-password-file   # Save password (no more prompts)
```

**Cleanup and rebuild:**
```bash
task destroy   # Delete all VMs
task provision # Recreate VMs
task rke2      # Redeploy cluster
```

**Diagnostics:**
```bash
task verify-proxmox  # Check Proxmox connection
task debug-vault     # Show credentials (masked)
task list-hosts      # Show inventory
task ping            # Test SSH to all nodes
```

## Authentication (100% Key-Based)

### Proxmox API - Encrypted Vault

Credentials stored in `group_vars/all/vault.yml` (AES256 encrypted):
- `vault_proxmox_api_token_id`
- `vault_proxmox_api_token_secret`

Managed via: `task vault-create`, `task vault-edit`, `task vault-view`

### VM SSH Access - Key Pairs

**Public key** → Injected via cloud-init  
**Private key** → Used by Ansible

Configured in `group_vars/all/vars.yml`:
```yaml
ssh_public_key_file: ~/.ssh/proxmox.pub
ssh_private_key_file: ~/.ssh/proxmox
```

## Network

- **Subnet**: 192.168.68.0/24
- **Gateway**: 192.168.68.1
- **Masters**: .100-.102 (VM IDs: 100-102)
- **Workers**: .110-.112 (VM IDs: 110-112)

## Access Kubernetes Cluster

After RKE2 deployment, the kubeconfig is automatically downloaded to `rke2.yaml` in the workspace root.

**Quick Access:**
```bash
# Use directly
kubectl --kubeconfig=rke2.yaml get nodes

# Or set environment variable
export KUBECONFIG=$PWD/rke2.yaml
kubectl get nodes
```

**Alternative - Manual download:**
```bash
# Copy kubeconfig from master
scp -i ~/.ssh/proxmox root@192.168.68.100:/etc/rancher/rke2/rke2.yaml ~/.kube/config

# Update server IP
sed -i 's/127.0.0.1/192.168.68.100/g' ~/.kube/config
```

📚 **See [docs/KUBECONFIG-USAGE.md](docs/KUBECONFIG-USAGE.md) for complete kubeconfig guide**

## Cleanup

```bash
task destroy  # Delete all VMs
task clean    # Remove temp files
```

## Troubleshooting

**Template not found:**
```bash
task verify-proxmox  # Lists all templates
```

**SSH connection fails:**
```bash
ssh -i ~/.ssh/proxmox root@192.168.68.100  # Test manually
```

**Vault errors:**
```bash
task vault-view  # Verify credentials
```

**Cloud-init stuck:**
- Check template has cloud-init installed
- Verify SSH key is in template's cloud-init config

## Documentation

📚 **All documentation is organized in the [`docs/`](docs/) folder**

👉 **Start here: [docs/DOCUMENTATION-INDEX.md](docs/DOCUMENTATION-INDEX.md)** - Complete navigation guide

### General Documentation
- **[docs/QUICKSTART.md](docs/QUICKSTART.md)** - Step-by-step deployment guide
- **[docs/SETUP.md](docs/SETUP.md)** - Complete setup instructions
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Debug and common issues
- **[docs/AUTHENTICATION.md](docs/AUTHENTICATION.md)** - Security and auth setup
- **[docs/VAULT.md](docs/VAULT.md)** - Ansible Vault management

### RKE2 Kubernetes Documentation
- **[docs/RKE2-QUICKSTART.md](docs/RKE2-QUICKSTART.md)** - RKE2 quick start
- **[docs/RKE2-DEPLOYMENT.md](docs/RKE2-DEPLOYMENT.md)** - Complete RKE2 deployment guide
- **[docs/RKE2-SETUP.md](docs/RKE2-SETUP.md)** - RKE2 setup and prerequisites
- **[docs/RKE2-IMPLEMENTATION-SUMMARY.md](docs/RKE2-IMPLEMENTATION-SUMMARY.md)** - Implementation architecture
- **[docs/KUBECONFIG-USAGE.md](docs/KUBECONFIG-USAGE.md)** - Kubeconfig download and usage
- **[docs/FIXED-README.md](docs/FIXED-README.md)** - Recent fixes and updates

## Features

✅ Token-based Proxmox API auth (encrypted vault)  
✅ SSH key authentication (no passwords)  
✅ Automated VM cloning and configuration  
✅ Cloud-init for network setup  
✅ RKE2 Kubernetes deployment (lablabs.rke2 collection)  
✅ High Availability cluster support  
✅ Complete lifecycle management  
✅ 30+ Taskfile commands  
✅ Comprehensive documentation

## Links

- [RKE2 Docs](https://docs.rke2.io/)
- [Proxmox API](https://pve.proxmox.com/wiki/Proxmox_VE_API)
- [Task](https://taskfile.dev/)

