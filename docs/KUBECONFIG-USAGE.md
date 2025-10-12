# Kubeconfig Usage Guide

## 📥 Automatic Download

Your RKE2 cluster is configured to automatically download the kubeconfig file to your workspace after deployment.

### Configuration

**Location**: `defaults/main.yml`

```yaml
rke2_download_kubeconf: true
rke2_download_kubeconf_file_name: rke2.yaml
rke2_download_kubeconf_path: "{{ playbook_dir }}/.."  # Workspace root
```

### Downloaded File Location

After running `task rke2` or `task cluster`, the kubeconfig will be at:

```
/Volumes/Workhub/Personal/Technology/Homelab/Proxmox/Proxmox-RKE2-Provisioner/rke2.yaml
```

**Security**: This file is already in `.gitignore` and will NOT be committed to git ✅

## 🔧 Using the Kubeconfig

### Option 1: Direct kubectl Usage

```bash
# From your workspace directory
kubectl --kubeconfig=rke2.yaml get nodes
kubectl --kubeconfig=rke2.yaml get pods -A
kubectl --kubeconfig=rke2.yaml cluster-info
```

### Option 2: Set as Environment Variable (Temporary)

```bash
# Set for current shell session
export KUBECONFIG=/Volumes/Workhub/Personal/Technology/Homelab/Proxmox/Proxmox-RKE2-Provisioner/rke2.yaml

# Now use kubectl normally
kubectl get nodes
kubectl get pods -A
```

### Option 3: Copy to Default Location

```bash
# Create .kube directory if it doesn't exist
mkdir -p ~/.kube

# Backup existing config (if any)
[ -f ~/.kube/config ] && cp ~/.kube/config ~/.kube/config.backup.$(date +%Y%m%d-%H%M%S)

# Copy the downloaded kubeconfig
cp rke2.yaml ~/.kube/config

# Update server IP (must point to your master node, not 127.0.0.1)
sed -i '' 's/127.0.0.1/192.168.68.100/g' ~/.kube/config

# Now kubectl works without specifying kubeconfig
kubectl get nodes
```

### Option 4: Merge with Existing Kubeconfig

If you have multiple clusters:

```bash
# Set the new config temporarily
export KUBECONFIG=~/.kube/config:./rke2.yaml

# View all contexts
kubectl config get-contexts

# Merge and save
kubectl config view --flatten > ~/.kube/config.new
mv ~/.kube/config.new ~/.kube/config

# Switch to RKE2 context
kubectl config use-context default
```

### Option 5: Add to Shell Profile (Permanent)

```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export KUBECONFIG=/Volumes/Workhub/Personal/Technology/Homelab/Proxmox/Proxmox-RKE2-Provisioner/rke2.yaml' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Now kubectl always uses this config
kubectl get nodes
```

## 🔍 Verify Kubeconfig

### Check Kubeconfig Contents

```bash
# View the config
cat rke2.yaml

# Should show:
# - Server URL (update if pointing to 127.0.0.1)
# - Certificate Authority Data
# - Client Certificate Data
# - Client Key Data
```

### Test Connection

```bash
kubectl --kubeconfig=rke2.yaml cluster-info

# Should show:
# Kubernetes control plane is running at https://192.168.68.100:6443
# CoreDNS is running at ...
```

### Check Cluster Nodes

```bash
kubectl --kubeconfig=rke2.yaml get nodes -o wide

# Should show all 6 nodes:
# master-01   Ready   control-plane,master
# master-02   Ready   control-plane,master
# master-03   Ready   control-plane,master
# worker-01   Ready   <none>
# worker-02   Ready   <none>
# worker-03   Ready   <none>
```

## ⚙️ Update Server IP (if needed)

The downloaded kubeconfig may reference `127.0.0.1`. Update it to your master node IP:

### macOS

```bash
# Update to first master IP
sed -i '' 's/127.0.0.1/192.168.68.100/g' rke2.yaml

# Verify the change
grep "server:" rke2.yaml
# Should show: server: https://192.168.68.100:6443
```

### Linux

```bash
# Update to first master IP
sed -i 's/127.0.0.1/192.168.68.100/g' rke2.yaml

# Verify the change
grep "server:" rke2.yaml
```

### Manual Edit

```bash
nano rke2.yaml

# Find:
server: https://127.0.0.1:6443

# Change to:
server: https://192.168.68.100:6443
```

## 🎯 Quick Commands

### Basic Cluster Operations

```bash
# Set kubeconfig for current session
export KUBECONFIG=/Volumes/Workhub/Personal/Technology/Homelab/Proxmox/Proxmox-RKE2-Provisioner/rke2.yaml

# Get nodes
kubectl get nodes

# Get all resources
kubectl get all -A

# Get pods in all namespaces
kubectl get pods -A

# Check cluster health
kubectl get componentstatuses
```

### Common Operations

```bash
# Create a namespace
kubectl create namespace test

# Deploy nginx
kubectl create deployment nginx --image=nginx -n test

# Expose nginx
kubectl expose deployment nginx --port=80 --type=ClusterIP -n test

# View services
kubectl get svc -n test

# Delete test resources
kubectl delete namespace test
```

## 🔒 Security Best Practices

### 1. File Permissions

```bash
# Restrict access to kubeconfig
chmod 600 rke2.yaml

# Verify permissions
ls -la rke2.yaml
# Should show: -rw-------
```

### 2. Keep It Secure

```bash
# NEVER commit kubeconfig to git (already in .gitignore ✅)
git status

# NEVER share kubeconfig publicly
# Contains full cluster admin access!
```

### 3. Backup Your Kubeconfig

```bash
# Create encrypted backup
tar czf rke2-kubeconfig-backup.tar.gz rke2.yaml
gpg --encrypt --recipient your-email@example.com rke2-kubeconfig-backup.tar.gz
rm rke2-kubeconfig-backup.tar.gz

# Store encrypted file safely
```

## 🔄 Re-download Kubeconfig

If you need to download the kubeconfig again:

### Option 1: Re-run Playbook

```bash
# Full deployment (will skip unchanged tasks)
task rke2
```

### Option 2: Manual Download

```bash
# SSH to master and copy
scp root@192.168.68.100:/etc/rancher/rke2/rke2.yaml ./rke2.yaml

# Update server IP
sed -i '' 's/127.0.0.1/192.168.68.100/g' rke2.yaml
```

### Option 3: Fetch Task

```bash
# Create a simple playbook to just fetch kubeconfig
ansible -i inventory/hosts.yml masters[0] -m fetch \
  -a "src=/etc/rancher/rke2/rke2.yaml dest=./rke2.yaml flat=yes" \
  --become
```

## 📋 Troubleshooting

### Kubeconfig Not Downloaded

**Check:**
```bash
# Verify setting in defaults/main.yml
grep "rke2_download_kubeconf:" defaults/main.yml
# Should be: true

# Check if file exists
ls -la rke2.yaml
```

**Solution:**
```bash
# Re-run the deployment
task rke2
```

### Connection Refused

**Error:**
```
The connection to the server 127.0.0.1:6443 was refused
```

**Solution:**
```bash
# Update server IP in kubeconfig
sed -i '' 's/127.0.0.1/192.168.68.100/g' rke2.yaml
```

### Certificate Issues

**Error:**
```
x509: certificate is valid for ..., not 192.168.68.100
```

**Solution:**
```bash
# Check server URL matches cluster setup
grep "server:" rke2.yaml

# If using HA, point to VIP or load balancer
sed -i '' 's/192.168.68.100/192.168.68.99/g' rke2.yaml  # If using VIP
```

### Permission Denied

**Error:**
```
error: error loading config file: open rke2.yaml: permission denied
```

**Solution:**
```bash
# Fix file permissions
chmod 600 rke2.yaml
```

## 🚀 Advanced Usage

### Multiple Clusters

Create context names for each cluster:

```bash
# Rename context in kubeconfig
kubectl config --kubeconfig=rke2.yaml rename-context default rke2-cluster

# View contexts
kubectl config get-contexts

# Switch between clusters
kubectl config use-context rke2-cluster
```

### kubie (Context Switcher)

Install `kubie` for easy context switching:

```bash
# macOS
brew install kubie

# Use kubie
kubie ctx rke2-cluster
kubie ns default
```

### k9s (Terminal UI)

Use `k9s` for a better terminal experience:

```bash
# macOS
brew install k9s

# Launch with specific kubeconfig
k9s --kubeconfig=rke2.yaml
```

## 📚 Additional Resources

- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Managing Multiple Kubeconfigs](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
- [kubectl Quick Reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)

---

## 🎯 Quick Reference

```bash
# Location of downloaded kubeconfig
./rke2.yaml

# Use directly
kubectl --kubeconfig=rke2.yaml get nodes

# Or set environment variable
export KUBECONFIG=$PWD/rke2.yaml
kubectl get nodes

# Update server IP
sed -i '' 's/127.0.0.1/192.168.68.100/g' rke2.yaml

# Copy to default location
mkdir -p ~/.kube
cp rke2.yaml ~/.kube/config
```

**Happy clustering!** 🎉

