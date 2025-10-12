# Authentication Setup Guide

This guide explains how to set up authentication for the RKE2 Proxmox Provisioner.

## Overview

This project requires **two separate authentication mechanisms**:

1. **Proxmox API Authentication** - To create and manage VMs via Proxmox API
2. **SSH Key Authentication** - To connect to and configure the VMs

## 1. Proxmox API Authentication

### Option A: API Tokens (Recommended)

API tokens are more secure than passwords and can have specific permissions.

#### Create API Token in Proxmox:

1. Log in to Proxmox web interface
2. Navigate to **Datacenter → Permissions → API Tokens**
3. Click **Add**
4. Fill in the details:
   - **User**: Select user (e.g., `root@pam`)
   - **Token ID**: Give it a name (e.g., `provisioner`)
   - **Privilege Separation**: Uncheck (or configure specific permissions)
5. Click **Add**
6. **Important**: Copy the secret immediately - it won't be shown again!

#### Set Environment Variables:

```bash
export PROXMOX_API_TOKEN_ID="root@pam!provisioner"
export PROXMOX_API_TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Or add to `.env` file:

```bash
# Create .env from template
cp env.example .env

# Edit .env and add your credentials
nano .env
```

Then source it:

```bash
source .env
```

#### Required Proxmox Permissions:

The API token needs these permissions:
- `VM.Allocate` - Create VMs
- `VM.Clone` - Clone from templates
- `VM.Config.Disk` - Configure disks
- `VM.Config.CPU` - Configure CPU
- `VM.Config.Memory` - Configure memory
- `VM.Config.Network` - Configure network
- `VM.Config.Options` - Configure other options
- `VM.PowerMgmt` - Start/stop VMs
- `Datastore.AllocateSpace` - Use storage

### Option B: Password Authentication (Not Recommended)

If you prefer to use password authentication:

```bash
export PROXMOX_PASSWORD="your-proxmox-password"
```

Then update `playbooks/provision-vms.yml`:

```yaml
vars:
  proxmox_api_user: root@pam
  proxmox_api_password: "{{ lookup('env', 'PROXMOX_PASSWORD') }}"
  # Comment out token lines
  # proxmox_api_token_id: "{{ lookup('env', 'PROXMOX_API_TOKEN_ID') }}"
  # proxmox_api_token_secret: "{{ lookup('env', 'PROXMOX_API_TOKEN_SECRET') }}"
```

## 2. SSH Key Authentication

SSH keys are used by Ansible to connect to the VMs after they're provisioned.

### Generate SSH Key (if you don't have one):

```bash
ssh-keygen -t rsa -b 4096 -C "rke2-provisioner" -f ~/.ssh/id_rsa
```

### Configure in Inventory:

Edit `inventory/hosts.yml`:

```yaml
all:
  children:
    k8s_cluster:
      vars:
        ansible_user: root
        ansible_ssh_private_key_file: ~/.ssh/id_rsa  # Your SSH private key path
        ansible_python_interpreter: /usr/bin/python3
```

### Add Public Key to VM Template:

Your Proxmox VM template (ID 9000) must have your SSH public key configured via cloud-init:

1. In Proxmox, select the template VM
2. Go to **Cloud-Init** tab
3. Add your SSH public key:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
4. Paste the key into the **SSH public key** field
5. Regenerate the cloud-init image if needed

Alternatively, set it in the playbook:

```yaml
vars:
  vm_sshkeys: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
```

### Verify SSH Key Permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

## 3. Test Authentication

### Test Proxmox API:

```bash
task proxmox:ping
```

Or manually:

```bash
ansible localhost -m community.general.proxmox_node_info \
  -a "api_host=192.168.68.65 \
      api_user=root@pam \
      api_token_id=$PROXMOX_API_TOKEN_ID \
      api_token_secret=$PROXMOX_API_TOKEN_SECRET"
```

### Test SSH Connectivity:

After VMs are provisioned:

```bash
task ping
```

Or manually:

```bash
ansible all -i inventory/hosts.yml -m ping
```

## 4. Security Best Practices

### For Proxmox API:

✅ **DO:**
- Use API tokens instead of passwords
- Create dedicated user for automation
- Use minimal required permissions
- Rotate tokens regularly
- Store secrets in environment variables or vault
- Never commit credentials to git

❌ **DON'T:**
- Use root password in scripts
- Store credentials in playbooks
- Share API tokens
- Use same token for multiple projects

### For SSH Keys:

✅ **DO:**
- Use dedicated SSH keys for automation
- Protect private keys with proper permissions (600)
- Use passphrase for extra security
- Regularly rotate SSH keys
- Use ssh-agent for passphrase management

❌ **DON'T:**
- Use personal SSH keys for automation
- Share private keys
- Store private keys in version control
- Use same key for multiple purposes

## 5. Troubleshooting

### Proxmox API Connection Failed

```bash
# Check if environment variables are set
echo $PROXMOX_API_TOKEN_ID
echo $PROXMOX_API_TOKEN_SECRET

# Test API access manually
curl -k -H "Authorization: PVEAPIToken=$PROXMOX_API_TOKEN_ID=$PROXMOX_API_TOKEN_SECRET" \
  https://192.168.68.65:8006/api2/json/nodes
```

### SSH Connection Failed

```bash
# Test direct SSH connection
ssh -i ~/.ssh/id_rsa root@192.168.68.100

# Check SSH key permissions
ls -la ~/.ssh/id_rsa

# Verify key is in VM
ssh -i ~/.ssh/id_rsa root@192.168.68.100 "cat ~/.ssh/authorized_keys"
```

### Cloud-init Not Working

- Verify cloud-init is installed in template: `cloud-init --version`
- Check cloud-init logs: `/var/log/cloud-init.log`
- Regenerate cloud-init drive in Proxmox
- Verify network configuration in template

## 6. Alternative: Ansible Vault

For enhanced security, use Ansible Vault to encrypt credentials:

```bash
# Create encrypted vault file
ansible-vault create group_vars/all/vault.yml

# Add your credentials
proxmox_api_token_id: "root@pam!provisioner"
proxmox_api_token_secret: "your-secret-here"
```

Update playbook to use vault variables:

```yaml
vars:
  proxmox_api_token_id: "{{ vault_proxmox_api_token_id }}"
  proxmox_api_token_secret: "{{ vault_proxmox_api_token_secret }}"
```

Run playbook with vault:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml --ask-vault-pass
```

## Summary

| What | Method | Where to Configure |
|------|--------|-------------------|
| Proxmox API | API Token | Environment variables |
| VM SSH Access | SSH Private Key | `inventory/hosts.yml` |
| VM Template | SSH Public Key | Cloud-init in template |

**Quick Setup:**

```bash
# 1. Set Proxmox API credentials
export PROXMOX_API_TOKEN_ID="root@pam!provisioner"
export PROXMOX_API_TOKEN_SECRET="your-secret"

# 2. Verify SSH key exists
ls -la ~/.ssh/id_rsa

# 3. Ensure public key is in VM template
cat ~/.ssh/id_rsa.pub

# 4. Test and deploy
task proxmox:ping
task cluster
```

