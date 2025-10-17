# RKE2 Proxmox Provisioner - Setup Instructions

## Authentication Overview

This project uses **100% key-based authentication** - no passwords anywhere:

### 🔑 Proxmox API Authentication
- **Method**: API Tokens only (no passwords)
- **Required**: `PROXMOX_API_TOKEN_ID` and `PROXMOX_API_TOKEN_SECRET`

### 🔐 VM SSH Authentication  
- **Method**: SSH private/public keys only (no passwords)
- **Required**: SSH key pair configured in inventory and VM template

---

## Quick Setup

### 1. Install Required Dependencies

#### Install Ansible Collections
```bash
task install
# or
ansible-galaxy collection install -r requirements.yml
```

#### Install Python Dependencies (Required for Proxmox modules)

The `community.proxmox` collection requires Python libraries:

**Option A: Using Homebrew (Recommended for macOS)**
```bash
brew install python-requests
```

**Option B: Using pip with user install**
```bash
python3 -m pip install --user proxmoxer requests
```

**Option C: Using pipx (isolated environment)**
```bash
brew install pipx
pipx install ansible --include-deps
```

### 2. Create Proxmox API Token

1. Log into Proxmox web interface
2. Navigate to: **Datacenter** → **Permissions** → **API Tokens**
3. Click **Add**
4. Fill in:
   - **User**: `root@pam` (or your user)
   - **Token ID**: `provisioner`
   - **Privilege Separation**: Uncheck (or configure specific permissions)
5. Click **Add**
6. **Important**: Copy the secret immediately (shown only once!)

### 3. Configure SSH Keys

#### Generate SSH key (if needed):
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

#### Set proper permissions:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

#### Add public key to Proxmox template:
```bash
# Display your public key
cat ~/.ssh/id_rsa.pub

# In Proxmox, edit template (ID 9000):
# Cloud-Init → SSH public key → Paste your key
```

### 4. Configure Environment

```bash
# Copy example file
cp env.example .env

# Edit with your credentials
nano .env
```

Add your values:
```bash
export PROXMOX_API_TOKEN_ID="root@pam!provisioner"
export PROXMOX_API_TOKEN_SECRET="your-actual-token-secret"
export ANSIBLE_PRIVATE_KEY_FILE="$HOME/.ssh/id_rsa"
export SSH_PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
```

Load environment:
```bash
source .env
```

### 5. Update Inventory

Edit `inventory/hosts.yml`:
```yaml
all:
  children:
    k8s_cluster:
      children:
        masters:
          hosts:
            master-01:
              ansible_host: 192.168.68.100
            # ... more hosts
      
      vars:
        ansible_user: root
        ansible_ssh_private_key_file: ~/.ssh/id_rsa
        ansible_python_interpreter: /usr/bin/python3
```

### 6. Update Playbook Settings

Edit `playbooks/provision-vms.yml`:
- Update `proxmox_host` with your Proxmox IP
- Update `proxmox_node` with your node name
- Update storage and network settings

---

## Verification

### Test Ansible Collections
```bash
ansible-galaxy collection list | grep -E "community\.(general|proxmox)"
```

Expected output:
```
community.general     11.4.0
community.proxmox     1.3.0
```

### Test Python Dependencies
```bash
python3 -c "import proxmoxer; import requests; print('✓ Dependencies OK')"
```

### Test Proxmox API Connection
```bash
task proxmox-ping
```

### Test SSH Connectivity (after VMs are created)
```bash
task ping
```

### Check Playbook Syntax
```bash
task syntax
```

---

## Deployment

### Full Deployment
```bash
# Deploy everything (collections + VMs + RKE2)
task cluster
```

### Step by Step
```bash
# 1. Provision VMs
task provision

# 2. Verify connectivity
task ping

# 3. Deploy RKE2
task rke2
```

### Dry Run (Check mode)
```bash
task provision-check
task rke2-check
```

---

## Troubleshooting

### Issue: Module not found error
```
ERROR! couldn't resolve module/action 'community.proxmox.proxmox_kvm'
```

**Solution**: Install the collection
```bash
ansible-galaxy collection install community.proxmox --force
```

### Issue: Python module not found
```
ModuleNotFoundError: No module named 'proxmoxer'
```

**Solution**: Install Python dependencies
```bash
python3 -m pip install --user proxmoxer requests
```

### Issue: API Token authentication failed
```
ERROR! 401 - Authentication failure
```

**Solutions**:
1. Verify token is correct: `echo $PROXMOX_API_TOKEN_ID`
2. Check token has proper permissions in Proxmox
3. Ensure token format is correct: `user@realm!token-name`

### Issue: SSH connection failed
```
Permission denied (publickey)
```

**Solutions**:
1. Verify SSH key exists: `ls -la ~/.ssh/id_rsa`
2. Check permissions: `chmod 600 ~/.ssh/id_rsa`
3. Verify public key is in VM template's cloud-init
4. Test manual SSH: `ssh -i ~/.ssh/id_rsa root@192.168.68.100`

### Issue: Template not found
```
ERROR! Template 9000 not found
```

**Solution**: 
1. Verify template exists in Proxmox
2. Update `proxmox_template_id` in playbook if different

---

## Security Notes

### ✅ What We Use (Secure)
- ✅ Proxmox API Tokens (not passwords)
- ✅ SSH private/public keys (not passwords)
- ✅ Token-based authentication everywhere
- ✅ Keys stored locally (not in code)

### ❌ What We Don't Use
- ❌ No Proxmox passwords
- ❌ No VM user passwords
- ❌ No plaintext credentials in files
- ❌ No credentials in version control

### Best Practices
1. **Never commit**:
   - `.env` file
   - SSH private keys
   - API token secrets

2. **File permissions**:
   - Private keys: `600` (read/write by owner only)
   - Public keys: `644` (readable by all)
   - `.ssh` directory: `700`

3. **Rotate regularly**:
   - API tokens every 90 days
   - SSH keys every 180 days

---

## File Structure

```
RKE2-Provisioner/
├── .env                          # Your credentials (gitignored)
├── env.example                   # Template for .env
├── inventory/hosts.yml           # SSH key configured here
├── playbooks/provision-vms.yml   # Auto-loads SSH public key
├── roles/provision-vms/          # Uses token auth only
└── requirements.yml              # Includes community.proxmox
```

---

## Quick Reference

| Component | Authentication | Configuration |
|-----------|---------------|---------------|
| **Proxmox API** | API Token | `PROXMOX_API_TOKEN_ID` + `SECRET` |
| **VM SSH** | Private Key | `ansible_ssh_private_key_file` |
| **Cloud-init** | Public Key | Auto-loaded from `~/.ssh/id_rsa.pub` |

---

## Next Steps

After setup is complete:

1. ✅ Test provision: `task provision-check`
2. ✅ Provision VMs: `task provision`
3. ✅ Test connectivity: `task ping`
4. ✅ Deploy RKE2: `task rke2`
5. ✅ Access cluster: Copy kubeconfig from master node

Happy clustering! 🚀

