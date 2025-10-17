# Semaphore Taskfile Quick Reference

This document provides a quick reference for all Semaphore-related Taskfile commands.

## 🚀 Quick Start Commands

### Single Server Deployment
```bash
task semaphore-single    # Deploy single Semaphore server (recommended for testing)
```

### High Availability Deployment
```bash
task semaphore-ha        # Deploy HA Semaphore setup (production ready)
```

### Full Infrastructure Deployment
```bash
task semaphore-cluster   # Deploy complete Semaphore infrastructure
```

## 📦 Provisioning Commands

### All Infrastructure
```bash
task semaphore-provision              # Provision all Semaphore VMs
task semaphore-provision-check        # Dry-run provisioning
```

### Component-Specific Provisioning
```bash
task semaphore-provision-servers      # Provision server VMs only
task semaphore-provision-databases    # Provision database VMs only
task semaphore-provision-agents       # Provision agent VMs only
task semaphore-provision-ha           # Provision HA infrastructure
```

## 🔧 Deployment Commands

### All Servers
```bash
task semaphore-deploy                 # Deploy to all servers
task semaphore-deploy-check           # Dry-run deployment
```

### Specific Targets
```bash
task semaphore-deploy-servers         # Deploy to server hosts only
task semaphore-deploy-primary         # Deploy to primary server only
```

## 🔍 Management Commands

### Service Management
```bash
task semaphore-status                 # Check service status
task semaphore-start                  # Start services
task semaphore-stop                   # Stop services
task semaphore-restart                # Restart services
```

### Monitoring & Logs
```bash
task semaphore-logs                   # View recent logs
task semaphore-logs-follow            # Follow logs in real-time
task semaphore-web-test               # Test web interface
task semaphore-facts                  # Gather system facts
```

### Backup Management
```bash
task semaphore-backup                 # Run manual backup
task semaphore-backup-status          # Check backup status
```

## 🧪 Testing & Validation

### Connectivity Tests
```bash
task semaphore-ping                   # Test SSH connectivity
task semaphore-check-inventory        # Verify inventory syntax
```

### Syntax & Linting
```bash
task semaphore-syntax                 # Check playbook syntax
task semaphore-lint                   # Lint playbooks
```

## 📋 Inventory Management

### List Hosts
```bash
task semaphore-list-hosts             # List all infrastructure hosts
```

## 🧹 Cleanup

```bash
task semaphore-clean                  # Clean temporary files
```

## 📚 Common Workflows

### 1. First-Time Setup (Single Server)
```bash
# Setup vault with credentials
task vault-create

# Deploy single Semaphore server
task semaphore-single

# Access at: http://192.168.68.120:3000
```

### 2. Production HA Setup
```bash
# Setup vault with credentials
task vault-create

# Deploy HA infrastructure
task semaphore-ha

# Access URLs:
# Primary: http://192.168.68.120:3000
# Secondary: http://192.168.68.121:3000
```

### 3. Full Infrastructure (All Components)
```bash
# Setup vault with credentials
task vault-create

# Deploy complete infrastructure
task semaphore-cluster

# Includes: servers, databases, agents, load balancer
```

### 4. Component-by-Component Deployment
```bash
# Setup vault with credentials
task vault-create

# Provision infrastructure
task semaphore-provision

# Wait for VMs to initialize, then test connectivity
task semaphore-ping

# Deploy Semaphore
task semaphore-deploy
```

### 5. Maintenance Workflow
```bash
# Check service status
task semaphore-status

# View logs if needed
task semaphore-logs

# Run backup
task semaphore-backup

# Restart services if needed
task semaphore-restart
```

### 6. Troubleshooting Workflow
```bash
# Check connectivity
task semaphore-ping

# Check service status
task semaphore-status

# View logs
task semaphore-logs

# Test web interface
task semaphore-web-test

# Check backup status
task semaphore-backup-status
```

## 🌐 Access Information

After successful deployment:

### Single Server
- **URL**: `http://192.168.68.120:3000`
- **SSH**: `ssh -i ~/.ssh/proxmox root@192.168.68.120`

### HA Setup
- **Primary**: `http://192.168.68.120:3000`
- **Secondary**: `http://192.168.68.121:3000`
- **SSH Primary**: `ssh -i ~/.ssh/proxmox root@192.168.68.120`
- **SSH Secondary**: `ssh -i ~/.ssh/proxmox root@192.168.68.121`

### Full Infrastructure
- **Servers**: `http://192.168.68.120:3000`, `http://192.168.68.121:3000`
- **Database**: `192.168.68.130`
- **Agents**: `192.168.68.140`, `192.168.68.141`
- **Load Balancer**: `http://192.168.68.150:80`

## 🔧 Configuration

### Vault Variables Required
Make sure your vault file contains:
```yaml
vault_proxmox_api_token_id: "your-token-id"
vault_proxmox_api_token_secret: "your-token-secret"
vault_semaphore_db_password: "secure-db-password"
vault_semaphore_access_key_encryption: "secure-encryption-key"
vault_mysql_root_password: "secure-mysql-root-password"
```

### Inventory Customization
Edit `inventory/semaphore.yml` to:
- Change IP addresses
- Modify VM specifications
- Add/remove hosts
- Update group configurations

## 🆘 Troubleshooting

### Common Issues

1. **VM Provisioning Fails**
   ```bash
   task semaphore-provision-check  # Check what would happen
   task vault-view                 # Verify credentials
   ```

2. **Deployment Fails**
   ```bash
   task semaphore-deploy-check     # Check what would happen
   task semaphore-ping             # Verify connectivity
   task semaphore-logs             # Check for errors
   ```

3. **Web Interface Not Accessible**
   ```bash
   task semaphore-status           # Check service status
   task semaphore-web-test         # Test web interface
   task semaphore-logs             # Check for errors
   ```

### Debug Commands
```bash
# Verbose deployment
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml -vvv

# Check specific host
ansible semaphore-01 -i inventory/semaphore.yml -m ping -vvv
```

## 📖 Additional Resources

- **Main Documentation**: `docs/SEMAPHORE-INFRASTRUCTURE.md`
- **Role Documentation**: `roles/deploy-semaphore/README.md`
- **Inventory Guide**: `inventory/README.md`
- **Full Taskfile Help**: `task help`
