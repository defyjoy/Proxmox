# RKE2 Setup Instructions

## 🚀 Quick Setup

Before deploying the RKE2 cluster, you need to install the required Ansible role and collections.

### Step 1: Install Role and Collections

```bash
# Recommended: Use the task command
task install

# Or manually with ansible-galaxy
ansible-galaxy install -r requirements.yml
```

This will install:
- `lablabs.rke2` - Official RKE2 Ansible role (from GitHub)
- `community.general` (>= 7.0.0) - Collection
- `community.proxmox` (>= 1.0.0) - Collection

### Step 2: Verify Installation

```bash
# Check installed role
ansible-galaxy role list | grep rke2

# Should show:
# - lablabs.rke2, (version)

# Or check the roles directory
ls -la roles/ | grep rke2
```

### Step 3: Test Syntax

```bash
# Verify playbook syntax
task syntax

# Or manually:
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml --syntax-check
```

### Step 4: Deploy

```bash
# Full deployment
task cluster

# Or step by step:
task provision  # Create VMs
task ping       # Verify connectivity
task rke2       # Deploy Kubernetes
```

## 📦 Role Details

### lablabs.rke2 Role

The `lablabs.rke2` role provides complete RKE2 installation and configuration:
- Automatic detection of master vs worker nodes based on inventory groups
- Installation of RKE2 server on master nodes
- Installation of RKE2 agent on worker nodes
- Configuration of networking and services

**Documentation**: https://github.com/lablabs/ansible-role-rke2

### Role Structure

```
roles/lablabs.rke2/
├── tasks/         # Main installation tasks
├── templates/     # Configuration templates
├── defaults/      # Default variables
├── handlers/      # Service handlers
└── vars/          # Role variables
```

## ⚙️ Configuration

All RKE2 configuration is in `defaults/main.yml`. The collection automatically reads these variables.

### Key Variables

```yaml
# defaults/main.yml
rke2_version: v1.25.3+rke2r1
rke2_token: defaultSecret12345  # CHANGE THIS!
rke2_type: server  # or agent
rke2_ha_mode: false
rke2_cni: [canal]
rke2_ingress_controller: ingress-nginx
```

### Group Names

The collection expects these inventory groups:

```yaml
# inventory/hosts.yml
k8s_cluster:        # Main cluster group
  masters:          # Server nodes
  workers:          # Agent nodes
```

These are defined in `defaults/main.yml`:
```yaml
rke2_cluster_group_name: k8s_cluster
rke2_servers_group_name: masters
rke2_agents_group_name: workers
```

## 🔍 Verification

### Before Deployment

Check your setup:

```bash
# Verify collections are installed
ansible-galaxy collection list

# Test inventory
task check-inventory

# Test connectivity
task ping

# Check playbook syntax
task syntax
```

### During Deployment

Monitor the deployment:

```bash
# Run with verbose output
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml -v

# Or very verbose
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml -vvv
```

### After Deployment

Verify cluster health:

```bash
# SSH to master
ssh root@192.168.68.100

# Check nodes
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
/var/lib/rancher/rke2/bin/kubectl get nodes

# Check pods
/var/lib/rancher/rke2/bin/kubectl get pods -A
```

## 🐛 Troubleshooting

### Role Not Found

**Error:**
```
ERROR! the role 'lablabs.rke2' was not found
```

**Solution:**
```bash
task install
# Or
ansible-galaxy install -r requirements.yml
```

### Role Install Fails

**Error:**
```
ERROR! Failed to resolve the requested dependencies map
```

**Solution:**
```bash
# Try with force
ansible-galaxy install -r requirements.yml --force

# Or install directly from GitHub
ansible-galaxy install git+https://github.com/lablabs/ansible-role-rke2.git,master
```

### Verify Role Path

```bash
# Show role paths
ansible-config dump | grep ROLES_PATH

# List installed roles
ansible-galaxy role list

# Check if role exists
ls -la roles/lablabs.rke2/
```

## 📝 Alternative: Manual Role Installation

If `requirements.yml` doesn't work:

```bash
# Install role directly from GitHub
ansible-galaxy install git+https://github.com/lablabs/ansible-role-rke2.git

# Or clone manually
git clone https://github.com/lablabs/ansible-role-rke2.git roles/lablabs.rke2
```

## 🔄 Update Role

To update to latest version:

```bash
# Update with force
ansible-galaxy install -r requirements.yml --force

# Or update directly
ansible-galaxy install git+https://github.com/lablabs/ansible-role-rke2.git --force
```

## 📚 Additional Resources

- **lablabs.rke2 GitHub**: https://github.com/lablabs/ansible-role-rke2
- **Ansible Galaxy**: https://galaxy.ansible.com/lablabs/rke2
- **RKE2 Documentation**: https://docs.rke2.io/

## ✅ Pre-Flight Checklist

Before running `task rke2`:

- [ ] Role and collections installed (`task install`)
- [ ] VMs provisioned (`task provision`)
- [ ] SSH connectivity verified (`task ping`)
- [ ] Vault credentials configured (`task vault-create`)
- [ ] Configuration reviewed (`defaults/main.yml`)
- [ ] Token changed from default (`rke2_token`)
- [ ] Playbook syntax checked (`task syntax`)

## 🎯 Ready to Deploy?

Once all collections are installed:

```bash
task rke2
```

For more details, see: **docs/RKE2-DEPLOYMENT.md**

