# Quick Start - Clone and Start VMs

This guide will help you clone and start your RKE2 cluster VMs from Proxmox template 9000.

## ✅ What's Already Configured

Your RKE2 Provisioner is ready with:

- ✅ **Ansible role** for VM provisioning (`roles/provision-vms/`)
- ✅ **Playbook** to orchestrate cloning (`playbooks/provision-vms.yml`)
- ✅ **Inventory** with 6 VMs defined:
  - Masters: 100, 101, 102 → IPs 192.168.68.100-102
  - Workers: 110, 111, 112 → IPs 192.168.68.110-112
- ✅ **Vault** for secure Proxmox API credentials
- ✅ **SSH keys** for VM authentication
- ✅ **Taskfile** with automation commands

## 🎯 Final Steps to Clone VMs

### Step 1: Find Your Template Name

Your template has ID **9000** but needs its **NAME** for cloning.

**Option A: Check via Proxmox Web UI**
```
1. Open: http://192.168.68.65:8006
2. Login with your credentials
3. Look for VM ID 9000 in the left panel
4. Note its NAME (e.g., "ubuntu-cloud-init", "ubuntu-template", etc.)
```

**Option B: Check via SSH** (if you have access)
```bash
ssh joydeep@192.168.68.65 "qm list | grep 9000"
# Output will show: 9000   template-name   ...
```

**Option C: Use diagnostic tool**
```bash
task verify-proxmox
# Will list all VMs and their names
```

### Step 2: Update Template Name

Edit `playbooks/provision-vms.yml` line 15:

```yaml
proxmox_template_name: "YOUR-ACTUAL-TEMPLATE-NAME"  # Change this!
```

Replace `YOUR-ACTUAL-TEMPLATE-NAME` with the name you found in Step 1.

### Step 3: Verify Vault Password

Make sure you have vault password set up:

```bash
# Option 1: Save password file (no prompts)
task vault-password-file
# Enter your vault password

# Option 2: Will prompt each time
# Just use: task provision (will ask for password)
```

### Step 4: Clone and Start VMs

```bash
# Dry-run first (recommended)
task provision-check

# Then actually provision
task provision
```

## 🚀 What Will Happen

When you run `task provision`:

1. **Clone VMs from template**
   - Creates 6 new VMs (IDs: 100-102, 110-112)
   - Full clones (not linked)
   - Storage: `local`

2. **Configure VMs**
   - Set CPU cores: 2
   - Set memory: 4096 MB
   - Set disk size: 32 GB
   - Configure network: vmbr0

3. **Cloud-init setup**
   - Set static IPs (from inventory)
   - Inject SSH public key (~/.ssh/id_rsa.pub)
   - Set hostname
   - Configure gateway: 192.168.68.1

4. **Start VMs**
   - Power on all VMs
   - Wait for SSH connectivity (port 22)
   - Timeout: 300 seconds

5. **Post-provisioning**
   - Gather system facts
   - Display VM information

## 📊 Expected Output

```
TASK [Clone VM from template ubuntu-cloud-init (ID 9000)]
changed: [master-01] => VM 100 cloned successfully
changed: [master-02] => VM 101 cloned successfully
changed: [master-03] => VM 102 cloned successfully
changed: [worker-01] => VM 110 cloned successfully
changed: [worker-02] => VM 111 cloned successfully
changed: [worker-03] => VM 112 cloned successfully

TASK [Configure cloned VM]
changed: [master-01] => CPU, memory, network configured

TASK [Start VM]
changed: [master-01] => VM started

TASK [Wait for VM to be reachable]
ok: [master-01] => SSH is ready

... (similar for all VMs)

PLAY RECAP
master-01: ok=8 changed=4
master-02: ok=8 changed=4
master-03: ok=8 changed=4
worker-01: ok=8 changed=4
worker-02: ok=8 changed=4
worker-03: ok=8 changed=4
```

## ⏱️ How Long Will It Take?

- **Clone operation**: 2-5 minutes per VM
- **Configuration**: 30 seconds per VM
- **Start and wait**: 1-2 minutes per VM
- **Total**: ~10-15 minutes for all 6 VMs

## 🔧 Troubleshooting

### Error: "Template does not exist"
```bash
# Verify template name
task verify-proxmox

# Update proxmox_template_name in playbook
```

### Error: "VM already exists"
```bash
# Delete existing VMs in Proxmox first
# Or change VM IDs in playbook:
#   master_vm_id_start: 200  # Different IDs
#   worker_vm_id_start: 210
```

### Error: "Storage not found"
```bash
# Update storage name in playbook
# Check available storage in Proxmox
```

### Error: "API authentication failed"
```bash
# Verify vault credentials
task vault-view

# Re-create vault if needed
task vault-edit
```

### Error: "Node not found"
```bash
# Update proxmox_node in group_vars/all/vars.yml
# Check node name in Proxmox
```

## ✅ Verification After Provisioning

```bash
# Test SSH to all VMs
task ping

# Should see:
# master-01 | SUCCESS => pong
# master-02 | SUCCESS => pong
# ... etc
```

## 🎯 Next Steps After VMs Are Running

Once VMs are cloned and started:

```bash
# Deploy RKE2 Kubernetes cluster
task rke2

# Or do full deployment in one go
task cluster  # provision + rke2
```

## 📝 Summary of Commands

```bash
# 1. Find template name (if needed)
task verify-proxmox

# 2. Update playbooks/provision-vms.yml
#    proxmox_template_name: "actual-name"

# 3. Save vault password (optional)
task vault-password-file

# 4. Clone and start VMs
task provision

# 5. Verify VMs are accessible
task ping

# 6. Deploy RKE2
task rke2
```

## 🚀 Ready to Go!

Once you update the template name, run:

```bash
task provision
```

Your 6 VMs will be cloned, configured, and started automatically! 🎉

