# RKE2 Kubernetes Cluster Deployment Guide

This guide explains how to deploy a production-ready RKE2 Kubernetes cluster using the `lablabs.rke2` Ansible collection.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Verification](#verification)
- [Access Cluster](#access-cluster)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The RKE2 deployment playbook (`playbooks/rke2-ansible.yaml`) uses the official `lablabs.rke2` Ansible role to:

- Deploy RKE2 master/server nodes in HA configuration
- Deploy RKE2 worker/agent nodes
- Configure networking and CNI (Canal by default)
- Set up Ingress Controller (nginx-ingress by default)
- Provide production-ready Kubernetes cluster

### Architecture

Based on your inventory:
- **3 Master nodes**: master-01, master-02, master-03
- **3 Worker nodes**: worker-01, worker-02, worker-03
- **High Availability**: Full HA setup with multiple control plane nodes

## ✅ Prerequisites

### 1. Install Ansible Role and Collections

```bash
task install
# Or manually:
ansible-galaxy install -r requirements.yml
```

This will install:
- `lablabs.rke2` - RKE2 deployment role (from GitHub)
- `community.general` (>= 7.0.0) - General utilities collection
- `community.proxmox` (>= 1.0.0) - Proxmox integration collection

### 2. Provision VMs

Ensure VMs are provisioned and accessible:

```bash
# Provision all VMs
task provision

# Wait for VMs to be ready (30 seconds)
sleep 30

# Test connectivity
task ping
```

### 3. System Requirements

Each node should have:
- **CPU**: 2+ cores (4+ recommended for masters)
- **RAM**: 4GB+ (8GB+ recommended for masters)
- **Disk**: 40GB+ free space
- **OS**: Ubuntu 20.04/22.04, Rocky Linux 8/9, or Debian 11/12
- **Network**: Static IP addresses configured
- **SSH**: Root access or sudo user configured

## 🚀 Quick Start

### Full Deployment (One Command)

```bash
# Complete cluster deployment: install dependencies + provision VMs + install RKE2
task cluster
```

### Individual Steps

```bash
# Step 1: Install dependencies
task install

# Step 2: Provision VMs
task provision

# Step 3: Wait for VMs to initialize
sleep 30

# Step 4: Test connectivity
task ping

# Step 5: Deploy RKE2 cluster
task rke2
```

### Dry Run (Check Mode)

```bash
# Test what would happen without making changes
task rke2-check
```

## ⚙️ Configuration

### Main Configuration File

All RKE2 configuration is in `defaults/main.yml`. Key settings:

```yaml
# RKE2 Version
rke2_version: v1.25.3+rke2r1

# Cluster Token (change in production!)
rke2_token: defaultSecret12345

# High Availability
rke2_ha_mode: false
rke2_ha_mode_keepalived: true

# CNI Plugin
rke2_cni: [canal]

# Ingress Controller
rke2_ingress_controller: ingress-nginx

# Network Configuration
rke2_cluster_cidr:
  - 10.42.0.0/16
rke2_service_cidr:
  - 10.43.0.0/16
```

### Important Settings to Review

#### 1. Cluster Token

**⚠️ CHANGE THIS IN PRODUCTION!**

```yaml
# defaults/main.yml
rke2_token: defaultSecret12345  # Change this!
```

Or use vault:

```yaml
# group_vars/all/vault.yml
rke2_token: "{{ vault_rke2_token }}"
```

#### 2. High Availability Mode

For true HA with 3 masters, enable:

```yaml
rke2_ha_mode: true
rke2_ha_mode_keepalived: true
# Set a VIP for the cluster
rke2_api_ip: "192.168.68.99"  # Virtual IP for HA
```

#### 3. RKE2 Version

Specify the exact version:

```yaml
rke2_version: v1.28.3+rke2r1  # Latest stable
```

Or use a channel:

```yaml
rke2_channel: stable  # or latest, stable, v1.28, etc.
```

#### 4. Download Kubeconfig

To automatically download kubeconfig to your local machine:

```yaml
rke2_download_kubeconf: true
rke2_download_kubeconf_path: /tmp
rke2_download_kubeconf_file_name: rke2.yaml
```

### Inventory Configuration

Your inventory is in `inventory/hosts.yml`:

```yaml
all:
  children:
    k8s_cluster:
      children:
        masters:
          hosts:
            master-01:
              ansible_host: 192.168.68.100
            master-02:
              ansible_host: 192.168.68.101
            master-03:
              ansible_host: 192.168.68.102
        
        workers:
          hosts:
            worker-01:
              ansible_host: 192.168.68.110
            worker-02:
              ansible_host: 192.168.68.111
            worker-03:
              ansible_host: 192.168.68.112
```

## 📦 Deployment

### Standard Deployment

```bash
task rke2
```

This will:
1. ✅ Prepare all nodes (disable swap, load kernel modules, configure networking)
2. ✅ Install RKE2 on master nodes sequentially
3. ✅ Install RKE2 on worker nodes in parallel
4. ✅ Wait for all nodes to join the cluster
5. ✅ Display cluster status and information

### Verbose Deployment

For detailed output:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml -v
```

Extra verbose:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml -vvv
```

### Deployment to Specific Nodes

Deploy only to masters:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml --limit masters
```

Deploy only to workers:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml --limit workers
```

## 🔍 Verification

### Check Cluster Status

The playbook automatically verifies:
- Node status (all nodes Ready)
- Pod status (all system pods Running)
- Cluster info and connectivity

### Manual Verification

SSH to the first master node:

```bash
ssh root@192.168.68.100
```

Check nodes:

```bash
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
/var/lib/rancher/rke2/bin/kubectl get nodes -o wide
```

Check pods:

```bash
/var/lib/rancher/rke2/bin/kubectl get pods -A
```

Check cluster info:

```bash
/var/lib/rancher/rke2/bin/kubectl cluster-info
```

### Health Checks

```bash
# On master node
/var/lib/rancher/rke2/bin/kubectl get componentstatuses
/var/lib/rancher/rke2/bin/kubectl get cs
```

## 🔐 Access Cluster

### Option 1: From Master Node

```bash
ssh root@192.168.68.100
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
alias kubectl="/var/lib/rancher/rke2/bin/kubectl"
kubectl get nodes
```

### Option 2: Download Kubeconfig

Enable in `defaults/main.yml`:

```yaml
rke2_download_kubeconf: true
rke2_download_kubeconf_path: ~/.kube
rke2_download_kubeconf_file_name: config
```

Then:

```bash
# After deployment
kubectl --kubeconfig=/tmp/rke2.yaml get nodes

# Or move to default location
mkdir -p ~/.kube
cp /tmp/rke2.yaml ~/.kube/config

# Update server IP (if needed)
kubectl config set-cluster default --server=https://192.168.68.100:6443
```

### Option 3: Manual Copy

```bash
# Copy kubeconfig from master
scp root@192.168.68.100:/etc/rancher/rke2/rke2.yaml ~/.kube/rke2-config

# Edit the server IP
sed -i 's/127.0.0.1/192.168.68.100/g' ~/.kube/rke2-config

# Use it
export KUBECONFIG=~/.kube/rke2-config
kubectl get nodes
```

## 🎨 Customization

### Enable High Availability

Edit `defaults/main.yml`:

```yaml
rke2_ha_mode: true
rke2_ha_mode_keepalived: true
rke2_api_ip: "192.168.68.99"  # Virtual IP
```

### Change CNI Plugin

```yaml
# Use Cilium instead of Canal
rke2_cni: [cilium]

# Or Calico
rke2_cni: [calico]
```

### Add Custom Manifests

```yaml
rke2_custom_manifests:
  - /path/to/custom/manifest.yaml
```

### Configure Node Taints

```yaml
# Taint master nodes (no workloads on masters)
rke2_server_node_taints:
  - 'CriticalAddonsOnly=true:NoExecute'
  - 'node-role.kubernetes.io/control-plane:NoSchedule'
```

### Add Additional SANs

For custom DNS or IPs:

```yaml
rke2_additional_sans:
  - kubernetes.example.com
  - 192.168.68.200
  - lb.k8s.local
```

### Custom Registries

```yaml
rke2_custom_registry_mirrors:
  - name: docker.io
    endpoint: 
      - "https://registry.example.com"
```

### Airgap Installation

For offline environments:

```yaml
rke2_airgap_mode: true
rke2_airgap_implementation: copy
rke2_airgap_copy_sourcepath: /path/to/local/artifacts
```

## 🐛 Troubleshooting

### Check RKE2 Service Status

```bash
# On any node
systemctl status rke2-server  # On masters
systemctl status rke2-agent   # On workers
```

### View RKE2 Logs

```bash
# Server logs (master)
journalctl -u rke2-server -f

# Agent logs (worker)
journalctl -u rke2-agent -f
```

### Common Issues

#### 1. Nodes Not Joining

**Problem**: Worker nodes not appearing in cluster

**Solution**:
```bash
# Check token matches on all nodes
cat /etc/rancher/rke2/config.yaml

# Check connectivity to master
telnet 192.168.68.100 9345

# Check firewall
systemctl status firewalld
```

#### 2. Pods Not Starting

**Problem**: System pods stuck in Pending or CrashLoopBackOff

**Solution**:
```bash
# Check pod details
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl top nodes
kubectl describe node <node-name>
```

#### 3. Networking Issues

**Problem**: Pods can't communicate

**Solution**:
```bash
# Check CNI pods
kubectl get pods -n kube-system | grep -E 'canal|calico|cilium'

# Verify IP forwarding
sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables

# Check routes
ip route
```

#### 4. High Availability Not Working

**Problem**: VIP not responding

**Solution**:
```bash
# Check keepalived
systemctl status keepalived
journalctl -u keepalived -f

# Verify VIP
ip addr show
ping 192.168.68.99
```

### Reset and Reinstall

If you need to completely reset:

```bash
# On each node, run:
/usr/local/bin/rke2-uninstall.sh    # On masters
/usr/local/bin/rke2-agent-uninstall.sh  # On workers

# Then redeploy
task rke2
```

### Playbook Syntax Check

```bash
task syntax
```

### Ansible Lint

```bash
task lint
```

## 📚 Additional Resources

- [RKE2 Official Documentation](https://docs.rke2.io/)
- [lablabs.rke2 Role](https://github.com/lablabs/ansible-role-rke2)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [RKE2 GitHub Repository](https://github.com/rancher/rke2)

## 🔄 Upgrade Process

To upgrade RKE2:

1. Update version in `defaults/main.yml`:
   ```yaml
   rke2_version: v1.28.3+rke2r1
   ```

2. Run playbook:
   ```bash
   task rke2
   ```

The playbook will safely upgrade nodes one at a time.

## 🗑️ Cluster Removal

To completely remove the cluster:

```bash
# Destroy VMs
task destroy

# Or manually uninstall RKE2 on each node
ansible k8s_cluster -i inventory/hosts.yml -a "/usr/local/bin/rke2-uninstall.sh" -b
```

## 📝 Best Practices

1. ✅ **Always change the default token** in production
2. ✅ **Use Ansible Vault** for sensitive data
3. ✅ **Enable HA mode** for production clusters
4. ✅ **Backup etcd** regularly
5. ✅ **Test in check mode** before running
6. ✅ **Monitor cluster health** after deployment
7. ✅ **Document custom configurations**
8. ✅ **Keep RKE2 version pinned** (don't use `latest`)

---

**Happy Clustering! 🚀**

