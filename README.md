# RKE2 Proxmox Provisioner

Automated provisioning and deployment of RKE2 Kubernetes clusters on Proxmox VE using Ansible.

## Overview

This project automates the complete lifecycle of deploying a production-ready RKE2 Kubernetes cluster on Proxmox:

1. **Provision VMs** - Clone VMs from a Proxmox template
2. **Configure Networking** - Set up static IPs and cloud-init
3. **Deploy RKE2** - Install and configure RKE2 Kubernetes cluster

## Prerequisites

### Required Software

- **Ansible** >= 2.10
- **Task** (recommended) or **Make**
- **Python** >= 3.8
- **Proxmox VE** cluster with API access

### Proxmox Requirements

- VM template (ID: 9000) configured with:
  - Cloud-init support
  - Desired OS (Ubuntu/Debian recommended)
  - Required packages (qemu-guest-agent, etc.)

### Install Task (Optional but Recommended)

**macOS:**
```bash
brew install go-task
```

**Linux:**
```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
```

**Or use Make** - Already available on most systems

## Quick Start

### 1. Install Dependencies

```bash
task install
# or
make install
```

### 2. Configure Inventory

Edit `inventory/hosts.yml` with your target VMs' details:
- Hostnames
- IP addresses
- SSH credentials

### 3. Configure Authentication

**Create Proxmox API Token** in Proxmox UI:
- Datacenter → Permissions → API Tokens → Add
- User: `root@pam`, Token ID: `provisioner`

**Store credentials in encrypted vault**:

```bash
task vault-create
# Enter your credentials when prompted
# Choose a strong vault password
```

**Ensure SSH key is configured**:

```bash
# Generate if needed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Add public key to VM template cloud-init
cat ~/.ssh/id_rsa.pub
```

### 4. Deploy Complete Cluster

```bash
task cluster
# Enter your vault password when prompted
```

This will:
1. Install Ansible collections
2. Provision 6 VMs (3 masters + 3 workers) from template 9000
3. Wait for VMs to be ready
4. Install and configure RKE2 cluster

## Usage

### Using Task (Recommended)

```bash
# Show all available commands
task --list

# Show detailed help
task help

# Vault management (first time setup)
task vault-create      # Create encrypted vault
task vault-edit        # Edit credentials
task vault-view        # View vault contents

# Individual playbooks (prompts for vault password)
task provision         # Provision VMs only
task rke2             # Install RKE2 only
task all              # Run both playbooks

# Testing and validation
task ping             # Test SSH connectivity
task syntax           # Check playbook syntax
task provision-check  # Dry-run provision
task rke2-check       # Dry-run RKE2

# Cluster operations
task cluster          # Full deployment
task list-hosts       # List inventory hosts
```

### Using Make

```bash
# Show all available commands
make help

# Individual playbooks
make provision         # Provision VMs only
make rke2             # Install RKE2 only
make all              # Run both playbooks

# Testing and validation
make ping             # Test SSH connectivity
make syntax           # Check playbook syntax
make provision-check  # Dry-run provision
make rke2-check       # Dry-run RKE2

# Cluster operations
make cluster          # Full deployment
make list-hosts       # List inventory hosts
```

## Project Structure

```
.
├── Taskfile.yml              # Task runner configuration
├── Makefile                  # Make configuration
├── requirements.yml          # Ansible collection dependencies
├── ansible.cfg              # Ansible configuration (optional)
├── inventory/
│   └── hosts.yml            # Inventory file with host definitions
├── playbooks/
│   ├── provision-vms.yml    # VM provisioning playbook
│   └── rke2-ansible.yaml    # RKE2 installation playbook
├── roles/
│   └── provision-vms/       # VM provisioning role
│       ├── defaults/
│       │   └── main.yml     # Default variables
│       ├── tasks/
│       │   ├── main.yml     # Main tasks
│       │   └── clone_vm.yml # Clone task
│       ├── meta/
│       │   └── main.yml     # Role metadata
│       └── README.md        # Role documentation
└── defaults/
    └── main.yml             # RKE2 default configuration
```

## Configuration

### Inventory Configuration

The inventory file (`inventory/hosts.yml`) defines your cluster topology:

```yaml
all:
  children:
    k8s_cluster:
      children:
        masters:           # Control plane nodes
          hosts:
            master-01:
              ansible_host: 192.168.68.100
            master-02:
              ansible_host: 192.168.68.101
            master-03:
              ansible_host: 192.168.68.102
        
        workers:           # Worker nodes
          hosts:
            worker-01:
              ansible_host: 192.168.68.110
            worker-02:
              ansible_host: 192.168.68.111
            worker-03:
              ansible_host: 192.168.68.112
```

### Proxmox Configuration

Edit `playbooks/provision-vms.yml` to configure:

```yaml
vars:
  proxmox_host: 192.168.68.65        # Proxmox host IP
  proxmox_api_user: root@pam          # API user
  proxmox_node: pve                   # Proxmox node name
  proxmox_template_id: 9000           # Template VM ID
  vm_cores: 2                         # CPU cores per VM
  vm_memory: 4096                     # RAM in MB
  vm_disk_size: 32                    # Disk size in GB
  vm_storage: local-lvm               # Storage name
```

### RKE2 Configuration

Edit `defaults/main.yml` to customize RKE2:

```yaml
rke2_version: v1.25.3+rke2r1
rke2_token: defaultSecret12345
rke2_ha_mode: false
rke2_cni: [canal]
# ... many more options available
```

## VM ID Assignment

VMs are automatically assigned IDs:
- **Master nodes**: 200, 201, 202
- **Worker nodes**: 210, 211, 212

## Workflows

### Standard Deployment

```bash
# Full deployment from scratch
task install
task provision
task ping
task rke2
```

### Re-deploy RKE2 Only

```bash
# Re-install RKE2 on existing VMs
task rke2
```

### Check Before Apply

```bash
# Dry-run to see what would change
task provision-check
task rke2-check
```

### Troubleshooting

```bash
# Test connectivity
task ping

# List all hosts
task list-hosts

# Gather system facts
task facts

# Check playbook syntax
task syntax
```

## Authentication

This project uses **100% key-based authentication** - no passwords:

### 1. Proxmox API Authentication - Ansible Vault (Encrypted)

**Create and store credentials securely**:

```bash
# First time setup
task vault-create

# Edit existing vault
task vault-edit

# View vault contents
task vault-view
```

Credentials are stored encrypted in `group_vars/all/vault.yml`:
```yaml
vault_proxmox_api_token_id: "root@pam!provisioner"
vault_proxmox_api_token_secret: "your-secret"
```

### 2. SSH Key Authentication

Configure in `inventory/hosts.yml`:

```yaml
k8s_cluster:
  vars:
    ansible_user: root
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

SSH public key is automatically loaded from `~/.ssh/id_rsa.pub` and injected into VMs via cloud-init.

**Detailed guides**:
- [docs/AUTHENTICATION.md](docs/AUTHENTICATION.md) - Complete authentication guide
- [docs/VAULT.md](docs/VAULT.md) - Ansible Vault usage and advanced features

## Network Configuration

The default configuration uses:
- **Network**: 192.168.68.0/24
- **Gateway**: 192.168.68.1
- **Masters**: 192.168.68.100-102
- **Workers**: 192.168.68.110-112

Update `inventory/hosts.yml` and `playbooks/provision-vms.yml` to match your network.

## Accessing the Cluster

After deployment, the kubeconfig can be downloaded:

1. Set in `defaults/main.yml`:
```yaml
rke2_download_kubeconf: true
rke2_download_kubeconf_path: /tmp
```

2. Copy kubeconfig:
```bash
scp master-01:/etc/rancher/rke2/rke2.yaml ~/.kube/config
# Update server IP in the config
sed -i 's/127.0.0.1/192.168.68.100/g' ~/.kube/config
```

3. Verify:
```bash
kubectl get nodes
kubectl get pods -A
```

## Cleanup

```bash
# Remove temporary files
task clean

# or
make clean
```

To destroy VMs, use Proxmox UI or CLI.

## Troubleshooting

### Common Issues

1. **Connection timeout**
   - Verify network connectivity: `task ping`
   - Check firewall rules
   - Ensure SSH keys are configured

2. **Proxmox API errors**
   - Verify credentials: `echo $PROXMOX_PASSWORD`
   - Test API access manually
   - Check Proxmox user permissions

3. **VM provisioning fails**
   - Verify template 9000 exists
   - Check storage availability
   - Ensure sufficient resources

4. **RKE2 installation fails**
   - Check system requirements
   - Verify internet connectivity (if not airgap)
   - Review logs: `/var/log/rke2.log`

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- Create an issue in the repository
- Check existing documentation
- Review Ansible and RKE2 official docs

## References

- [RKE2 Documentation](https://docs.rke2.io/)
- [Proxmox VE API](https://pve.proxmox.com/wiki/Proxmox_VE_API)
- [Ansible Documentation](https://docs.ansible.com/)
- [Task Documentation](https://taskfile.dev/)

