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

**Store credentials securely:**
```bash
task vault-create
# Enter API token credentials
# Set vault password
```

**Save vault password (optional, for convenience):**
```bash
task vault-password-file
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

# Vault management
task vault-create           # Create encrypted vault
task vault-password-file    # Save vault password locally
task vault-edit            # Edit credentials

# VM lifecycle
task provision             # Clone and start VMs
task destroy              # Delete all VMs (with confirmation)
task verify-proxmox       # Check Proxmox and list templates

# Kubernetes
task rke2                 # Deploy RKE2 cluster
task cluster              # Full deployment (provision + RKE2)

# Diagnostics
task ping                 # Test SSH connectivity
task syntax               # Check playbook syntax
task debug-vault          # Show vault variables
```

## Project Structure

```
├── Taskfile.yml                      # Task automation (30+ commands)
├── ansible.cfg                       # Ansible configuration
├── requirements.yml                  # Collection dependencies
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
│   ├── provision-vms/               # VM cloning role
│   └── destroy-vms/                 # VM deletion role
└── defaults/main.yml                # RKE2 configuration
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

`group_vars/all/vault.yml` contains:
```yaml
vault_proxmox_api_token_id: "user@pam!token"
vault_proxmox_api_token_secret: "secret"
```

## Common Workflows

**Full deployment:**
```bash
task cluster  # provision + RKE2
```

**Step by step:**
```bash
task provision  # Clone VMs
task ping      # Verify SSH
task rke2      # Deploy K8s
```

**Cleanup and rebuild:**
```bash
task destroy   # Delete VMs
task provision # Recreate
```

**Diagnostics:**
```bash
task verify-proxmox  # Check Proxmox
task debug-vault     # Show credentials (masked)
task list-hosts      # Show inventory
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

After RKE2 deployment:

```bash
# Copy kubeconfig from master
scp -i ~/.ssh/proxmox root@192.168.68.100:/etc/rancher/rke2/rke2.yaml ~/.kube/config

# Update server IP
sed -i 's/127.0.0.1/192.168.68.100/g' ~/.kube/config

# Verify
kubectl get nodes
```

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

- **QUICKSTART.md** - Step-by-step deployment guide
- **SETUP.md** - Complete setup instructions
- **docs/RKE2-DEPLOYMENT.md** - RKE2 cluster deployment guide (comprehensive)
- **docs/VAULT.md** - Ansible Vault management
- **docs/AUTHENTICATION.md** - Security and auth setup
- **TROUBLESHOOTING.md** - Debug and common issues

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

