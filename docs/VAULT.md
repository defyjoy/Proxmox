# Ansible Vault Setup Guide

This guide explains how to use Ansible Vault to securely store your Proxmox API credentials.

## Why Use Ansible Vault?

✅ **Advantages:**
- Credentials encrypted at rest
- Can be safely committed to version control (when encrypted)
- No need for environment variables
- Password-protected access
- Industry-standard security practice

❌ **Disadvantages of Environment Variables:**
- Visible in shell history
- Can leak in logs
- Not encrypted
- Easy to accidentally expose

## Quick Start

### 1. Create Encrypted Vault

```bash
task vault-create
```

This will:
1. Copy the example template
2. Open editor for you to add credentials
3. Encrypt the file with a password you provide

**Enter your actual credentials:**
```yaml
---
vault_proxmox_api_token_id: "root@pam!provisioner"
vault_proxmox_api_token_secret: "your-actual-secret-here"
```

### 2. Use Vault with Playbooks

All playbook tasks now include `--ask-vault-pass`:

```bash
task provision     # Will prompt for vault password
task rke2          # Will prompt for vault password
task cluster       # Will prompt for vault password
```

## Vault Management Commands

### Create New Vault
```bash
task vault-create
```

### Edit Existing Vault
```bash
task vault-edit
# or directly:
ansible-vault edit group_vars/all/vault.yml
```

### View Vault Contents
```bash
task vault-view
# or directly:
ansible-vault view group_vars/all/vault.yml
```

### Change Vault Password
```bash
task vault-rekey
# or directly:
ansible-vault rekey group_vars/all/vault.yml
```

### Encrypt Unencrypted Vault
```bash
task vault-encrypt
# or directly:
ansible-vault encrypt group_vars/all/vault.yml
```

### Decrypt Vault (Temporary)
```bash
task vault-decrypt
# ⚠️ WARNING: This makes the file unencrypted!
```

## Advanced: Vault Password File

To avoid typing the vault password every time:

### Option 1: Password File (Less Secure)

```bash
# Create password file
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Add to .gitignore (already included)
# .vault_pass
```

Update `ansible.cfg`:
```ini
[defaults]
vault_password_file = .vault_pass
```

### Option 2: Script to Retrieve Password

```bash
# Create password script
cat > .vault_pass.sh << 'EOF'
#!/bin/bash
# Retrieve password from secure location
# Examples: keychain, 1Password CLI, etc.
security find-generic-password -a "$USER" -s ansible-vault -w 2>/dev/null
EOF

chmod 700 .vault_pass.sh
```

Update `ansible.cfg`:
```ini
[defaults]
vault_password_file = .vault_pass.sh
```

**Store password in macOS Keychain:**
```bash
security add-generic-password -a "$USER" -s ansible-vault -w
# Enter your vault password when prompted
```

### Option 3: Using 1Password CLI

```bash
cat > .vault_pass.sh << 'EOF'
#!/bin/bash
op read "op://Private/Ansible Vault/password"
EOF

chmod 700 .vault_pass.sh
```

## File Structure

```
RKE2-Provisioner/
├── group_vars/
│   └── all/
│       ├── vars.yml              # Non-sensitive variables
│       ├── vault.yml             # Encrypted credentials (gitignored)
│       └── vault.yml.example     # Example template
├── .vault_pass                   # Optional password file (gitignored)
├── .vault_pass.sh                # Optional password script (gitignored)
└── ansible.cfg                   # Can reference vault_password_file
```

## How It Works

### Variables File (`group_vars/all/vars.yml`)
```yaml
---
# Non-sensitive configuration
proxmox_host: 192.168.68.65
proxmox_api_user: root@pam
proxmox_node: pve

# References to vault variables
proxmox_api_token_id: "{{ vault_proxmox_api_token_id }}"
proxmox_api_token_secret: "{{ vault_proxmox_api_token_secret }}"
```

### Vault File (`group_vars/all/vault.yml`)
```yaml
---
# Encrypted credentials
vault_proxmox_api_token_id: "root@pam!provisioner"
vault_proxmox_api_token_secret: "actual-secret-value"
```

### Playbook Usage
Ansible automatically:
1. Loads `group_vars/all/vars.yml`
2. Decrypts `group_vars/all/vault.yml` (with password)
3. Substitutes vault variables into playbook variables
4. Uses credentials for Proxmox API calls

## Security Best Practices

### ✅ DO:
- Use strong vault passwords (16+ characters)
- Keep vault password secure (password manager)
- Commit encrypted vault files to git
- Use vault password file with chmod 600
- Rotate vault passwords regularly
- Use different vault passwords per project

### ❌ DON'T:
- Don't commit unencrypted vault files
- Don't share vault passwords via email/chat
- Don't use weak passwords
- Don't leave vault decrypted
- Don't commit .vault_pass files

## Troubleshooting

### Error: "Vault is not encrypted"
```bash
ansible-vault encrypt group_vars/all/vault.yml
```

### Error: "Incorrect vault password"
- Verify you're using the correct password
- Check if vault was encrypted with different password
- Use `task vault-view` to test password

### Error: "Vault file not found"
```bash
# Create new vault
task vault-create

# Or copy from example
cp group_vars/all/vault.yml.example group_vars/all/vault.yml
# Edit and encrypt
ansible-vault encrypt group_vars/all/vault.yml
```

### Error: "vault_proxmox_api_token_id is undefined"
- Ensure vault.yml contains the variable
- Check vault file is properly encrypted
- Verify vault password is correct

### Forgot Vault Password
Unfortunately, there's no way to recover a forgotten vault password. You'll need to:
1. Create a new vault file: `task vault-create`
2. Enter your credentials again
3. Use a new password

## Integration with CI/CD

### GitLab CI
```yaml
variables:
  ANSIBLE_VAULT_PASSWORD: $VAULT_PASSWORD  # Set in CI/CD variables

before_script:
  - echo "$ANSIBLE_VAULT_PASSWORD" > .vault_pass
  - chmod 600 .vault_pass

deploy:
  script:
    - ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml
```

### GitHub Actions
```yaml
- name: Create vault password file
  run: |
    echo "${{ secrets.ANSIBLE_VAULT_PASSWORD }}" > .vault_pass
    chmod 600 .vault_pass

- name: Run playbook
  run: ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml
```

## Multiple Vaults

You can have different vaults for different environments:

```
group_vars/
├── all/
│   ├── vars.yml
│   └── vault.yml           # Common secrets
├── production/
│   ├── vars.yml
│   └── vault.yml           # Production secrets
└── staging/
    ├── vars.yml
    └── vault.yml           # Staging secrets
```

Use different vault IDs:
```bash
ansible-vault create --vault-id prod@prompt group_vars/production/vault.yml
ansible-playbook playbook.yml --vault-id prod@prompt
```

## Quick Reference

| Task | Command |
|------|---------|
| Create vault | `task vault-create` |
| Edit vault | `task vault-edit` |
| View vault | `task vault-view` |
| Change password | `task vault-rekey` |
| Encrypt file | `task vault-encrypt` |
| Decrypt file | `task vault-decrypt` |
| Run with vault | `task provision` (prompts for password) |

## Migrating from Environment Variables

If you're currently using environment variables:

1. Create vault:
```bash
task vault-create
```

2. Add your credentials to vault:
```yaml
vault_proxmox_api_token_id: "root@pam!provisioner"
vault_proxmox_api_token_secret: "your-secret"
```

3. Remove environment variables:
```bash
# Remove from .env or shell profile
unset PROXMOX_API_TOKEN_ID
unset PROXMOX_API_TOKEN_SECRET
```

4. Test:
```bash
task provision-check
# Enter vault password when prompted
```

## Summary

- **Vault file location**: `group_vars/all/vault.yml`
- **Password**: Prompted when running playbooks
- **Encryption**: AES256
- **Safe to commit**: Yes (when encrypted)
- **Management**: Use `task vault-*` commands

For more information: https://docs.ansible.com/ansible/latest/user_guide/vault.html

