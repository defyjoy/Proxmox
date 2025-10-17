# Semaphore Infrastructure Deployment

This document describes the Semaphore CI/CD infrastructure deployment using dedicated inventory and playbooks.

## Overview

The Semaphore infrastructure consists of several components:

- **Semaphore Servers**: Main CI/CD application servers
- **Database Servers**: Dedicated MySQL/MariaDB servers (optional)
- **Agent Servers**: Distributed execution agents
- **Load Balancers**: High availability and SSL termination

## Inventory Structure

### `inventory/semaphore.yml`

The dedicated Semaphore inventory file provides:

- **Organized Groups**: Separate groups for different infrastructure components
- **Host-specific Variables**: Individual VM configurations per server
- **Global Variables**: Shared configuration across all Semaphore infrastructure
- **Flexible Deployment**: Support for single-server to full HA deployments

### Server Groups

#### `semaphore_servers`
- Primary Semaphore application servers
- Default: `semaphore-01` (192.168.68.120)
- HA: `semaphore-02` (192.168.68.121)

#### `semaphore_databases`
- Dedicated database servers (optional)
- Default: `semaphore-db-01` (192.168.68.130)

#### `semaphore_agents`
- Distributed execution agents
- Default: `semaphore-agent-01`, `semaphore-agent-02`

#### `semaphore_loadbalancer`
- Load balancer for HA deployments
- Default: `semaphore-lb-01` (192.168.68.150)

#### `semaphore_infrastructure`
- Parent group containing all Semaphore components
- Used for provisioning all infrastructure at once

## Deployment Workflow

### 1. Provision Infrastructure

```bash
# Provision all Semaphore infrastructure
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml

# Provision specific components
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit semaphore_servers
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit semaphore_databases
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit semaphore_agents
```

### 2. Deploy Semaphore

```bash
# Deploy to all Semaphore servers
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml

# Deploy to specific servers
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore-01
```

### 3. Verify Deployment

```bash
# Test connectivity
ansible -i inventory/semaphore.yml semaphore_infrastructure -m ping

# Check service status
ansible -i inventory/semaphore.yml semaphore_servers -m systemd -a "name=semaphore"
```

## Configuration

### Host Variables

Each host can have specific configuration:

```yaml
semaphore-01:
  ansible_host: 192.168.68.120
  semaphore_vm_id: 120
  semaphore_cores: 2
  semaphore_memory: 4096
  semaphore_disk: 50
  semaphore_description: "Primary Semaphore CI/CD Server"
```

### Global Variables

Shared configuration for all Semaphore infrastructure:

```yaml
# Semaphore Configuration
semaphore_version: "2.8.93"
semaphore_port: 3000
semaphore_interface: "0.0.0.0"

# Database Configuration
semaphore_db_host: "localhost"
semaphore_db_port: 3306
semaphore_db_name: "semaphore"
semaphore_db_user: "semaphore"

# Security Configuration
semaphore_ldap_enabled: false
semaphore_telemetry_enabled: false
```

## Deployment Scenarios

### Single Server Deployment

For simple deployments, use just the primary server:

```bash
# Provision single server
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit semaphore-01

# Deploy Semaphore
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore-01
```

### High Availability Deployment

For production HA deployments:

```bash
# Provision HA infrastructure
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit "semaphore_servers,semaphore_loadbalancer"

# Deploy Semaphore to both servers
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore_servers

# Configure load balancer (separate playbook needed)
ansible-playbook -i inventory/semaphore.yml playbooks/configure-loadbalancer.yml
```

### Distributed Deployment

For large-scale deployments with dedicated agents:

```bash
# Provision all infrastructure
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml

# Deploy Semaphore servers
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore_servers

# Deploy database servers
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore_databases

# Deploy agent servers
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore_agents
```

## Network Configuration

### Default Network Layout

```
192.168.68.120 - semaphore-01 (Primary Server)
192.168.68.121 - semaphore-02 (HA Server)
192.168.68.130 - semaphore-db-01 (Database Server)
192.168.68.140 - semaphore-agent-01 (Agent 1)
192.168.68.141 - semaphore-agent-02 (Agent 2)
192.168.68.150 - semaphore-lb-01 (Load Balancer)
```

### Firewall Rules

Default firewall configuration:

- **Port 22**: SSH access
- **Port 3000**: Semaphore web interface
- **Port 3001**: Semaphore agents (if configured)
- **Port 3306**: MySQL access (if external database)

## Access Information

### Web Interface

After deployment, access Semaphore at:

- **Primary**: `http://192.168.68.120:3000`
- **HA**: `http://192.168.68.121:3000`
- **Load Balancer**: `http://192.168.68.150:80` (if configured)

### SSH Access

```bash
# Access primary server
ssh -i ~/.ssh/proxmox root@192.168.68.120

# Access HA server
ssh -i ~/.ssh/proxmox root@192.168.68.121

# Access database server
ssh -i ~/.ssh/proxmox root@192.168.68.130
```

## Management Commands

### Service Management

```bash
# Check service status
ansible -i inventory/semaphore.yml semaphore_servers -m systemd -a "name=semaphore"

# Restart services
ansible -i inventory/semaphore.yml semaphore_servers -m systemd -a "name=semaphore state=restarted"

# Stop services
ansible -i inventory/semaphore.yml semaphore_servers -m systemd -a "name=semaphore state=stopped"
```

### Backup Management

```bash
# Run manual backup
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "/opt/semaphore/bin/backup.sh"

# Check backup status
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "ls -la /opt/semaphore-backups/"
```

### Log Management

```bash
# View service logs
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "journalctl -u semaphore -f"

# View backup logs
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "tail -f /var/log/semaphore/backup.log"
```

## Troubleshooting

### Common Issues

1. **VM Provisioning Fails**
   - Check Proxmox API credentials in vault
   - Verify template ID exists
   - Check network connectivity

2. **Semaphore Deployment Fails**
   - Check MySQL service status
   - Verify database credentials
   - Check firewall rules

3. **Web Interface Not Accessible**
   - Verify service is running
   - Check port configuration
   - Verify firewall rules

### Debug Commands

```bash
# Debug provisioning
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit semaphore-01 -vvv

# Debug deployment
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml --limit semaphore-01 -vvv

# Check connectivity
ansible -i inventory/semaphore.yml semaphore_infrastructure -m ping -vvv
```

## Security Considerations

1. **Change Default Passwords**: Update all default passwords in vault files
2. **Encryption Keys**: Change Semaphore access key encryption
3. **Firewall**: UFW is configured by default
4. **SSL/TLS**: Consider setting up reverse proxy with SSL
5. **Network Segmentation**: Consider separate network for Semaphore infrastructure

## Backup and Recovery

### Automated Backups

- **Database Backups**: Daily at 2:00 AM
- **Retention**: 30 days (configurable)
- **Location**: `/opt/semaphore-backups/`
- **Compression**: gzip compressed

### Manual Backup

```bash
# Create manual backup
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "/opt/semaphore/bin/backup.sh"
```

### Recovery

```bash
# Restore from backup
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "gunzip -c /opt/semaphore-backups/semaphore_backup_YYYYMMDD_HHMMSS.sql.gz | mysql -u semaphore -p semaphore"
```

## Scaling

### Horizontal Scaling

To add more servers:

1. Add new hosts to appropriate groups in `inventory/semaphore.yml`
2. Provision new VMs
3. Deploy Semaphore to new servers

### Vertical Scaling

To increase resources:

1. Update host variables in `inventory/semaphore.yml`
2. Re-provision VMs with new specifications
3. Redeploy Semaphore

## Monitoring

### Health Checks

```bash
# Check all services
ansible -i inventory/semaphore.yml semaphore_infrastructure -m systemd -a "name=semaphore"

# Check web interface
ansible -i inventory/semaphore.yml semaphore_servers -m uri -a "url=http://localhost:3000"
```

### Log Monitoring

```bash
# Monitor service logs
ansible -i inventory/semaphore.yml semaphore_servers -m shell -a "journalctl -u semaphore --since '1 hour ago'"
```

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review logs for error messages
3. Check Semaphore documentation
4. Verify network connectivity and firewall rules
