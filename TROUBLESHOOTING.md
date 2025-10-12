# Variable Loading Troubleshooting

## Issue Found
❌ group_vars/all/vars.yml variables are NOT loading
❌ Even with explicit vars_files inclusion

## Root Cause Analysis

Ansible loads group_vars based on the inventory structure:
- Variables in `group_vars/all/` apply to all hosts
- Variables in `group_vars/k8s_cluster/` apply to k8s_cluster group
- Auto-loading depends on running playbook from project root

## Solution Options

### Option 1: Move to project root (RECOMMENDED)
Run playbooks from project root:
```bash
cd /path/to/RKE2-Provisioner
ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml --ask-vault-pass
```

### Option 2: Explicit vars_files with correct paths
Update playbook with absolute/correct relative paths:
```yaml
vars_files:
  - "{{ playbook_dir }}/../group_vars/all/vars.yml"
  - "{{ playbook_dir }}/../group_vars/all/vault.yml"
```

### Option 3: Set variables in playbook directly
```yaml
vars:
  proxmox_host: 192.168.68.65
  proxmox_api_user: joydeep@pam
  proxmox_node: pve-01
  vault_proxmox_api_token_id: "{{ lookup('file', '../group_vars/all/vault.yml') | from_yaml | json_query('vault_proxmox_api_token_id') }}"
```

### Option 4: Use Taskfile (EASIEST)
```bash
task provision  # Automatically runs from correct directory
```

## Testing Steps

1. **Verify you're in project root:**
   ```bash
   pwd  # Should show: /path/to/RKE2-Provisioner
   ls group_vars/all/  # Should show: vars.yml vault.yml
   ```

2. **Test variable loading:**
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml --ask-vault-pass --tags debug
   ```

3. **Check for errors:**
   - File not found → wrong directory or path
   - Vault errors → need vault password
   - Variables undefined → syntax error in vars file

## Quick Fix Commands

```bash
# From project root
cd /Volumes/Workhub/Personal/Technology/Homelab/Proxmox/RKE2-Provisioner

# Verify files exist
ls -la group_vars/all/

# Test with Taskfile (recommended)
task vault-password-file  # Save vault password
task provision           # Run provision
```

