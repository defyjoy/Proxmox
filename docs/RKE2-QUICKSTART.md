# RKE2 Deployment - Quick Start

## 🎯 Goal

Deploy a production-ready RKE2 Kubernetes cluster on your Proxmox VMs using the official `lablabs.rke2` Ansible collection.

## 📦 What Was Created

### 1. Main Playbook
**File**: `playbooks/rke2-ansible.yaml`

Comprehensive playbook that:
- ✅ Prepares all nodes (networking, kernel modules, swap, etc.)
- ✅ Installs RKE2 on master nodes (3 nodes)
- ✅ Installs RKE2 on worker nodes (3 nodes)
- ✅ Verifies cluster health
- ✅ Downloads kubeconfig (optional)
- ✅ Displays cluster information

### 2. Updated Requirements
**File**: `requirements.yml`

Added `lablabs.rke2` collection (>= 2.0.0)

### 3. Documentation
- **docs/RKE2-DEPLOYMENT.md** - Comprehensive deployment guide
- **docs/RKE2-SETUP.md** - Setup and installation instructions
- **docs/RKE2-QUICKSTART.md** - This file

### 4. Updated Files
- **README.md** - Added RKE2 references
- **Taskfile.yml** - Already had RKE2 tasks configured

## 🚀 Quick Deployment

### Option 1: Full Automated Deployment (Recommended)

```bash
# One command - does everything!
task cluster
```

This will:
1. Install Ansible collections
2. Provision 6 VMs from Proxmox template
3. Wait 30 seconds for initialization
4. Test connectivity
5. Deploy RKE2 cluster

### Option 2: Step-by-Step Deployment

```bash
# Step 1: Install dependencies
task install

# Step 2: Create VMs
task provision

# Step 3: Wait for VMs to initialize
sleep 30

# Step 4: Test connectivity
task ping

# Step 5: Deploy RKE2
task rke2
```

### Option 3: Manual Ansible Commands

```bash
# Install collections
ansible-galaxy collection install -r requirements.yml

# Provision VMs
ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml

# Deploy RKE2
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml
```

## ⏱️ Expected Duration

- **Collection Installation**: ~2 minutes
- **VM Provisioning**: ~5 minutes (6 VMs)
- **RKE2 Deployment**: ~10-15 minutes
- **Total**: ~20 minutes for full cluster

## 📋 Prerequisites

### Before You Start

✅ **Proxmox Setup**
- Proxmox VE is running
- API token created
- Template VM (ID: 9000) exists with cloud-init

✅ **Local Setup**
- Ansible >= 2.10 installed
- Task >= 3.0 installed
- SSH key pair generated
- Vault configured with credentials

✅ **Network**
- IPs available: 192.168.68.100-102, 192.168.68.110-112
- Gateway accessible: 192.168.68.1

### First-Time Setup

If this is your first time:

```bash
# 1. Create vault with Proxmox credentials
task vault-create

# 2. (Optional) Save vault password for convenience
task vault-password-file

# 3. Install collections
task install

# 4. Verify Proxmox connection
task verify-proxmox

# 5. Check inventory
task check-inventory
```

## 🎨 Configuration

### Default Configuration

The playbook uses `defaults/main.yml` with these settings:

```yaml
RKE2 Version: v1.25.3+rke2r1
Cluster Token: defaultSecret12345
HA Mode: Disabled
CNI: Canal
Ingress: nginx-ingress
Pod CIDR: 10.42.0.0/16
Service CIDR: 10.43.0.0/16
```

### ⚠️ Important: Change the Token!

**BEFORE deploying to production**, edit `defaults/main.yml`:

```bash
# Edit defaults
nano defaults/main.yml

# Find and change:
rke2_token: defaultSecret12345
# To something secure:
rke2_token: "your-super-secure-random-token-here"
```

Or use vault:
```bash
task vault-edit
# Add: vault_rke2_token: "secure-token"

# Then in defaults/main.yml:
rke2_token: "{{ vault_rke2_token }}"
```

### Enable High Availability

For true HA with 3 masters:

```bash
# Edit defaults/main.yml
nano defaults/main.yml

# Change these settings:
rke2_ha_mode: true
rke2_ha_mode_keepalived: true
rke2_api_ip: "192.168.68.99"  # Virtual IP for cluster
```

### Customize RKE2 Version

```bash
# In defaults/main.yml
rke2_version: v1.28.3+rke2r1  # Use latest stable
```

## 🔍 Monitoring Deployment

### Watch Progress

```bash
# Run with verbose output
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml -v

# Or very verbose (debug level)
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml -vvv
```

### Check Specific Nodes

```bash
# SSH to master
ssh root@192.168.68.100

# Watch RKE2 installation
journalctl -u rke2-server -f
```

## ✅ Verification

### After Deployment

The playbook automatically:
- ✅ Waits for all nodes to be Ready
- ✅ Displays node status
- ✅ Shows all pods
- ✅ Prints cluster info

### Manual Verification

```bash
# SSH to first master
ssh root@192.168.68.100

# Set kubeconfig
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# Check nodes
/var/lib/rancher/rke2/bin/kubectl get nodes -o wide

# Should show:
# master-01   Ready    control-plane,master   ...
# master-02   Ready    control-plane,master   ...
# master-03   Ready    control-plane,master   ...
# worker-01   Ready    <none>                ...
# worker-02   Ready    <none>                ...
# worker-03   Ready    <none>                ...
```

### Check System Pods

```bash
/var/lib/rancher/rke2/bin/kubectl get pods -A

# All pods should be Running or Completed
```

## 🔐 Access Cluster

### Option 1: From Master Node

```bash
ssh root@192.168.68.100
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
alias kubectl="/var/lib/rancher/rke2/bin/kubectl"
kubectl get nodes
```

### Option 2: Local kubectl

```bash
# Download kubeconfig
scp root@192.168.68.100:/etc/rancher/rke2/rke2.yaml ~/.kube/config

# Update server IP
sed -i 's/127.0.0.1/192.168.68.100/g' ~/.kube/config

# Test
kubectl get nodes
```

### Option 3: Auto-download (Configure in defaults/main.yml)

```yaml
rke2_download_kubeconf: true
rke2_download_kubeconf_path: ~/.kube
rke2_download_kubeconf_file_name: config
```

## 🧪 Test Deployment

Deploy a test application:

```bash
# Create test deployment
kubectl create deployment nginx --image=nginx --replicas=3

# Expose it
kubectl expose deployment nginx --port=80 --type=ClusterIP

# Check pods
kubectl get pods -l app=nginx

# Test connectivity
kubectl run test --rm -it --image=busybox -- wget -qO- http://nginx
```

## 🗑️ Cleanup

### Remove Cluster

```bash
# Destroy all VMs
task destroy
```

### Redeploy Fresh Cluster

```bash
# Destroy and recreate
task destroy
task cluster
```

### Uninstall RKE2 (Keep VMs)

```bash
# On each node:
ansible k8s_cluster -i inventory/hosts.yml -a "/usr/local/bin/rke2-uninstall.sh" -b
```

## 🐛 Troubleshooting

### Collection Not Found

```bash
# Install collections
task install
```

### VMs Not Accessible

```bash
# Test connectivity
task ping

# Check specific host
ssh root@192.168.68.100
```

### Deployment Failed

```bash
# Check logs on master
ssh root@192.168.68.100
journalctl -u rke2-server -f

# Check logs on worker
ssh root@192.168.68.110
journalctl -u rke2-agent -f
```

### Syntax Errors

```bash
# Check playbook syntax
task syntax

# Validate inventory
task check-inventory
```

## 📚 Next Steps

1. **Read Full Documentation**
   - `docs/RKE2-DEPLOYMENT.md` - Comprehensive guide
   - `docs/RKE2-SETUP.md` - Detailed setup

2. **Configure Ingress**
   ```bash
   kubectl get ingressclass
   kubectl get svc -n kube-system
   ```

3. **Deploy Applications**
   - Use Helm charts
   - Deploy with kubectl
   - Configure CI/CD

4. **Set Up Monitoring**
   - Install Prometheus
   - Install Grafana
   - Configure alerts

5. **Backup Configuration**
   - Backup etcd snapshots
   - Save kubeconfig
   - Document custom settings

## 🎯 Common Commands

```bash
# Full deployment
task cluster

# Deploy only RKE2
task rke2

# Check syntax
task syntax

# Dry run
task rke2-check

# Destroy cluster
task destroy

# Show all commands
task --list

# Get help
task help
```

## 📞 Support

- **Documentation**: See `docs/` folder
- **Troubleshooting**: See `TROUBLESHOOTING.md`
- **RKE2 Issues**: https://github.com/rancher/rke2/issues
- **Collection Issues**: https://github.com/lablabs/ansible-collection-rke2/issues

---

**Ready to deploy? Run: `task cluster`** 🚀

