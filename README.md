# 🚀 RKE2 Proxmox Provisioner

Automated provisioning and deployment of RKE2 Kubernetes clusters on Proxmox VE using Ansible.

## 📋 Overview

Complete automation for deploying production-ready RKE2 Kubernetes clusters on Proxmox:

1. **🖥️ Provision VMs** - Clone from template, configure resources
2. **🌐 Configure Network** - Static IPs via cloud-init
3. **☸️ Deploy RKE2** - Install Kubernetes cluster
4. **🔄 Manage Lifecycle** - Create, destroy, rebuild

## ✅ Prerequisites

- **Ansible** >= 2.10
- **Task** >= 3.0 (task runner)
- **Python** >= 3.8 with `proxmoxer` and `requests` libraries
- **Proxmox VE** with API access
- **VM template** (ID: 9000) with cloud-init support

### 📥 Install Task

**🍎 macOS:**
```bash
brew install go-task
```

**🐧 Linux:**
```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
```

## ⚡ Quick Start

### 1. 📦 Install Dependencies

```bash
task install
```

### 2. 🔐 Configure Authentication

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

**🔧 Manage vault later:**
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

### 3. ⚙️ Update Configuration

**Verify settings in `group_vars/all/vars.yml`:**
- Proxmox host IP
- Node name
- SSH key paths

### 4. 🚢 Deploy Cluster

```bash
task provision  # Clone and start 6 VMs
task ping       # Verify connectivity
task rke2       # Deploy Kubernetes
```

**⚡ Or all in one:**
```bash
task cluster
```

## 🛠️ Available Commands

```bash
# 📋 View all commands
task --list

# 📦 Setup & Installation
task install               # Install Ansible roles and collections

# 🔐 Vault Management (Credential Security)
task vault-create          # Create new encrypted vault file
task vault-edit            # Edit encrypted vault credentials
task vault-view            # View vault contents (read-only)
task vault-rekey           # Change vault password
task vault-password-file   # Save vault password locally (convenience)
task vault-password-remove # Remove saved vault password
task debug-vault           # Show vault variables (masked)

# 🖥️ VM Lifecycle
task provision             # Clone and start VMs from template
task destroy               # Delete all VMs (with confirmation)
task verify-proxmox        # Check Proxmox connection and list templates

# ☸️ Kubernetes / RKE2
task rke2                  # Deploy RKE2 cluster on provisioned VMs
task cluster               # Full deployment (install + provision + RKE2)
task rke2-check            # Dry-run RKE2 deployment
task rke2-remove           # Remove RKE2 from all nodes (keeps VMs)
task rke2-remove-force     # Remove RKE2 without confirmation

# 🔍 Diagnostics & Testing
task ping                  # Test SSH connectivity to all hosts
task syntax                # Check playbook syntax
task check-inventory       # Verify inventory file
task list-hosts            # List all hosts in inventory
```

## 🚀 Semaphore CI/CD Infrastructure

This project now includes comprehensive Semaphore CI/CD infrastructure deployment alongside the RKE2 Kubernetes cluster.

### 🎯 Semaphore Quick Start

**Complete Semaphore Setup (Recommended):**
```bash
# Setup vault with credentials
task vault-create

# Complete Semaphore infrastructure setup
task semaphore-setup
```

**Access your Semaphore instances:**
- Primary Server: http://192.168.68.120:3000
- Secondary Server: http://192.168.68.121:3000

### 🔧 Semaphore Commands

```bash
# 🚀 Complete Setup (Recommended)
task semaphore-setup       # Complete setup (provision + deploy)
task semaphore-setup-force # Complete setup without prompts

# 🖥️ Individual Operations
task semaphore-provision   # Provision Semaphore VMs only
task semaphore-deploy      # Deploy Semaphore on existing VMs

# 🏗️ Infrastructure Management
task semaphore-status      # Check all services status
task semaphore-logs        # View Semaphore service logs
task semaphore-web         # Test web interface accessibility
task semaphore-ping        # Test connectivity to all VMs

# 💥 Destruction
task semaphore-destroy     # Destroy all Semaphore VMs (with confirmation)
task semaphore-destroy-force # Force destroy (no confirmation)

# 🧹 Maintenance
task semaphore-clean       # Clean temporary files
```

### 📊 Semaphore Infrastructure

**6 VMs Deployed:**
- **2 Semaphore Servers** (HA Ready)
  - semaphore-01: 192.168.68.120:3000
  - semaphore-02: 192.168.68.121:3000
- **1 MySQL Database Server**: semaphore-db-01 (192.168.68.130)
- **2 Agent Servers**: semaphore-agent-01/02 (192.168.68.140-141)
- **1 Load Balancer**: semaphore-lb-01 (192.168.68.150)

### 🌐 Semaphore Features

- **High Availability**: Multiple server instances
- **Database**: Dedicated MySQL server with automated backups
- **Distributed Agents**: Multiple agent nodes for parallel execution
- **Load Balancing**: HAProxy load balancer for traffic distribution
- **Automated Backups**: Daily database backups with retention
- **Firewall Security**: UFW configured with minimal required ports
- **Service Management**: Systemd services with auto-restart

### 📁 Semaphore Project Structure

```
├── inventory/semaphore.yml              # Semaphore-specific inventory
├── playbooks/
│   ├── semaphore-setup.yml             # Complete setup (NEW)
│   ├── provision-semaphore-vms.yml     # VM provisioning
│   ├── deploy-semaphore.yml            # Semaphore deployment
│   └── destroy-semaphore-vms.yml       # VM destruction
├── roles/deploy-semaphore/             # Complete Semaphore role
│   ├── tasks/                          # Installation & configuration
│   ├── templates/                      # Config templates
│   └── defaults/main.yml               # Semaphore variables
└── docs/
    ├── SEMAPHORE-INFRASTRUCTURE.md     # Detailed documentation
    ├── TASKFILE-SEMAPHORE-QUICKREF.md  # Command reference
    └── inventory/README.md             # Inventory guide
```

## 📁 Project Structure

```
├── Taskfile.yml                      # Task automation (30+ commands)
├── ansible.cfg                       # Ansible configuration
├── requirements.yml                  # Role & collection dependencies
├── defaults/main.yml                 # RKE2 configuration (350+ variables)
├── inventory/
│   ├── hosts.yml                    # RKE2 cluster VMs (6 VMs)
│   └── semaphore.yml                # Semaphore infrastructure VMs (6 VMs)
├── group_vars/all/
│   ├── vars.yml                     # Proxmox & SSH settings
│   └── vault.yml                    # Encrypted API tokens
├── playbooks/
│   ├── provision-vms.yml            # Create RKE2 VMs
│   ├── destroy-vms.yml              # Delete RKE2 VMs
│   ├── rke2-ansible.yaml            # Deploy Kubernetes
│   ├── verify-proxmox.yml           # Diagnostics
│   ├── semaphore-setup.yml          # Complete Semaphore setup (NEW)
│   ├── provision-semaphore-vms.yml  # Create Semaphore VMs
│   ├── deploy-semaphore.yml         # Deploy Semaphore CI/CD
│   └── destroy-semaphore-vms.yml    # Delete Semaphore VMs
├── roles/
│   ├── lablabs.rke2/                # RKE2 deployment role
│   ├── provision-vms/               # VM cloning role
│   ├── destroy-vms/                 # VM deletion role
│   └── deploy-semaphore/            # Semaphore CI/CD deployment role
└── docs/                             # All documentation
    ├── QUICKSTART.md
    ├── SETUP.md
    ├── TROUBLESHOOTING.md
    ├── RKE2-*.md                    # RKE2 guides
    ├── SEMAPHORE-INFRASTRUCTURE.md  # Semaphore infrastructure guide
    ├── TASKFILE-SEMAPHORE-QUICKREF.md # Semaphore command reference
    └── inventory/README.md           # Inventory management guide
```

## ⚙️ Configuration

### 📊 Inventory (6 VMs)

**Masters:** 100-102 → 192.168.68.100-102  
**Workers:** 110-112 → 192.168.68.110-112

Edit `inventory/hosts.yml` to change IPs or add/remove nodes.

### 🔧 Proxmox Settings

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

### 🔒 Vault (Encrypted Credentials)

The encrypted vault file `group_vars/all/vault.yml` stores sensitive credentials:

```yaml
# Proxmox API authentication
vault_proxmox_api_token_id: "root@pam!your-token-id"
vault_proxmox_api_token_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# RKE2 cluster token (shared secret for nodes to join cluster)
vault_rke2_token: "your-secure-random-token-here"
```

**✨ Create vault:**
```bash
task vault-create    # Creates and encrypts vault.yml
```

**✏️ Edit vault:**
```bash
task vault-edit      # Edit encrypted vault with your editor
```

**🔑 Vault password options:**
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

## 🔄 Common Workflows

**🎯 First-time setup:**
```bash
task install        # Install dependencies
task vault-create   # Create encrypted credentials
# Edit the vault file that opens, add your tokens
# Save and exit - file will be encrypted
task verify-proxmox # Test Proxmox connection
```

**🚀 Full deployment:**
```bash
task cluster  # install + provision + RKE2 (complete automation)
```

**📝 Step by step:**
```bash
task provision  # Clone VMs from template
task ping       # Verify SSH connectivity
task rke2       # Deploy RKE2 Kubernetes cluster
```

**🔐 Manage credentials:**
```bash
task vault-edit            # Edit encrypted credentials
task vault-view            # View vault contents
task vault-rekey           # Change vault password
task vault-password-file   # Save password (no more prompts)
```

**🗑️ Cleanup and rebuild:**
```bash
# Remove only RKE2 (keeps VMs intact)
task rke2-remove    # Uninstall RKE2 from all nodes
task rke2           # Reinstall RKE2

# Complete rebuild (destroy VMs + recreate)
task destroy   # Delete all VMs
task provision # Recreate VMs
task rke2      # Deploy cluster

# Quick reset (remove RKE2 + redeploy)
task rke2-remove && task rke2
```

**🔍 Diagnostics:**
```bash
task verify-proxmox  # Check Proxmox connection
task debug-vault     # Show credentials (masked)
task list-hosts      # Show inventory
task ping            # Test SSH to all nodes
```

## 🔐 Authentication (100% Key-Based)

### 🔑 Proxmox API - Encrypted Vault

Credentials stored in `group_vars/all/vault.yml` (AES256 encrypted):
- `vault_proxmox_api_token_id`
- `vault_proxmox_api_token_secret`

Managed via: `task vault-create`, `task vault-edit`, `task vault-view`

### 🔑 VM SSH Access - Key Pairs

**Public key** → Injected via cloud-init  
**Private key** → Used by Ansible

Configured in `group_vars/all/vars.yml`:
```yaml
ssh_public_key_file: ~/.ssh/proxmox.pub
ssh_private_key_file: ~/.ssh/proxmox
```

## 🌐 Network

- **🔷 Subnet**: 192.168.68.0/24
- **🚪 Gateway**: 192.168.68.1
- **👑 Masters**: .100-.102 (VM IDs: 100-102)
- **⚙️ Workers**: .110-.112 (VM IDs: 110-112)

## ☸️ Access Kubernetes Cluster

After RKE2 deployment, the kubeconfig is automatically downloaded to `rke2.yaml` in the workspace root.

### 📍 kubectl Location

RKE2 installs kubectl at: **`/var/lib/rancher/rke2/bin/kubectl`**

**On Master Nodes:**
```bash
# SSH to master
ssh root@192.168.68.100

# kubectl alias is already configured
kubectl get nodes

# Or use full path
/var/lib/rancher/rke2/bin/kubectl --kubeconfig=/etc/rancher/rke2/rke2.yaml get nodes
```

**From Your Local Machine:**

**⚡ Quick Access:**
```bash
# Use downloaded kubeconfig directly
kubectl --kubeconfig=rke2.yaml get nodes

# Or set environment variable
export KUBECONFIG=$PWD/rke2.yaml
kubectl get nodes
```

**🔧 Alternative - Manual download:**
```bash
# Copy kubeconfig from master
scp -i ~/.ssh/proxmox root@192.168.68.100:/etc/rancher/rke2/rke2.yaml ~/.kube/config

# Update server IP
sed -i 's/127.0.0.1/192.168.68.100/g' ~/.kube/config
```

### 🗂️ Other RKE2 Binaries

All RKE2 binaries are located at `/var/lib/rancher/rke2/bin/`:
- `kubectl` - Kubernetes CLI
- `crictl` - Container runtime CLI  
- `ctr` - Containerd CLI
- `rke2` - RKE2 binary

📚 **See [docs/KUBECONFIG-USAGE.md](docs/KUBECONFIG-USAGE.md) for complete kubeconfig guide**

## 🧹 Cleanup

```bash
task destroy  # Delete all VMs
task clean    # Remove temp files
```

## 🔧 Troubleshooting

**❌ Template not found:**
```bash
task verify-proxmox  # Lists all templates
```

**🔌 SSH connection fails:**
```bash
ssh -i ~/.ssh/proxmox root@192.168.68.100  # Test manually
```

**🔒 Vault errors:**
```bash
task vault-view  # Verify credentials
```

**☁️ Cloud-init stuck:**
- Check template has cloud-init installed
- Verify SSH key is in template's cloud-init config

## 📚 Documentation

📚 **All documentation is organized in the [`docs/`](docs/) folder**

👉 **Start here: [docs/DOCUMENTATION-INDEX.md](docs/DOCUMENTATION-INDEX.md)** - Complete navigation guide

### 📖 General Documentation
- **[docs/QUICKSTART.md](docs/QUICKSTART.md)** - ⚡ Step-by-step deployment guide
- **[docs/SETUP.md](docs/SETUP.md)** - 🔧 Complete setup instructions
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - 🐛 Debug and common issues
- **[docs/AUTHENTICATION.md](docs/AUTHENTICATION.md)** - 🔐 Security and auth setup
- **[docs/VAULT.md](docs/VAULT.md)** - 🔒 Ansible Vault management

### ☸️ RKE2 Kubernetes Documentation
- **[docs/RKE2-QUICKSTART.md](docs/RKE2-QUICKSTART.md)** - 🚀 RKE2 quick start
- **[docs/RKE2-DEPLOYMENT.md](docs/RKE2-DEPLOYMENT.md)** - 📘 Complete RKE2 deployment guide
- **[docs/RKE2-SETUP.md](docs/RKE2-SETUP.md)** - ⚙️ RKE2 setup and prerequisites
- **[docs/RKE2-CIS-HARDENING.md](docs/RKE2-CIS-HARDENING.md)** - 🔒 CIS security hardening guide
- **[docs/RKE2-IMPLEMENTATION-SUMMARY.md](docs/RKE2-IMPLEMENTATION-SUMMARY.md)** - 🏗️ Implementation architecture
- **[docs/KUBECONFIG-USAGE.md](docs/KUBECONFIG-USAGE.md)** - 🔑 Kubeconfig download and usage
- **[docs/FIXED-README.md](docs/FIXED-README.md)** - 🔧 Recent fixes and updates

## ✨ Features

✅ Token-based Proxmox API auth (encrypted vault)  
✅ SSH key authentication (no passwords)  
✅ Automated VM cloning and configuration  
✅ Cloud-init for network setup  
✅ RKE2 Kubernetes deployment (lablabs.rke2 collection)  
✅ High Availability cluster support  
✅ Complete lifecycle management  
✅ 30+ Taskfile commands  
✅ Comprehensive documentation

## 🔗 Links

- 📘 [RKE2 Docs](https://docs.rke2.io/)
- 🔧 [Proxmox API](https://pve.proxmox.com/wiki/Proxmox_VE_API)
- ⚡ [Task](https://taskfile.dev/)

