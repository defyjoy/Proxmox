# Deploy Semaphore Role

This Ansible role deploys Semaphore CI/CD tool on Ubuntu/Debian systems with MySQL database backend.

## Features

- **Complete Semaphore Installation**: Downloads and installs the latest Semaphore binary
- **MySQL Database Setup**: Configures MySQL database with proper user and permissions
- **Systemd Service**: Creates and manages Semaphore as a system service
- **Firewall Configuration**: Configures UFW firewall rules
- **Automated Backups**: Sets up daily database backups with retention policy
- **Security Hardening**: Runs with non-root user and proper file permissions
- **Log Management**: Configures log rotation for backup logs

## Requirements

- Ubuntu 20.04+ or Debian 11+
- MySQL 5.7+ or MariaDB 10.3+
- Ansible 2.9+

## Role Variables

### Core Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `semaphore_version` | `2.8.93` | Semaphore version to install |
| `semaphore_port` | `3000` | Port for Semaphore web interface |
| `semaphore_interface` | `0.0.0.0` | Interface to bind to |

### Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `semaphore_db_driver` | `mysql` | Database driver (mysql/postgres) |
| `semaphore_db_host` | `localhost` | Database host |
| `semaphore_db_port` | `3306` | Database port |
| `semaphore_db_name` | `semaphore` | Database name |
| `semaphore_db_user` | `semaphore` | Database user |
| `semaphore_db_password` | `semaphore_password` | Database password |

### Security Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `semaphore_access_key_encryption` | `default_encryption_key_change_me` | Encryption key for access keys |
| `semaphore_ldap_enabled` | `false` | Enable LDAP authentication |
| `semaphore_telemetry_enabled` | `false` | Enable telemetry |

### Service Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `semaphore_service_enabled` | `true` | Enable service at boot |
| `semaphore_service_state` | `started` | Service state (started/stopped) |

### Backup Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `semaphore_backup_enabled` | `true` | Enable automated backups |
| `semaphore_backup_retention_days` | `30` | Backup retention period |

### Firewall Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `semaphore_firewall_enabled` | `true` | Enable firewall configuration |

## Dependencies

- `community.mysql` collection for database management

## Example Playbook

```yaml
---
- name: Deploy Semaphore CI/CD
  hosts: semaphore_servers
  become: true
  vars:
    semaphore_db_password: "{{ vault_semaphore_db_password }}"
    semaphore_access_key_encryption: "{{ vault_semaphore_access_key_encryption }}"
    mysql_root_password: "{{ vault_mysql_root_password }}"
  
  roles:
    - deploy-semaphore
```

## Usage

1. **Create VM**: First provision a VM using the existing `provision-vms.yml` playbook
2. **Update Inventory**: Add the new VM to the `semaphore_servers` group in `inventory/hosts.yml`
3. **Set Variables**: Configure required variables in `group_vars/all/vault.yml`
4. **Deploy**: Run the `deploy-semaphore.yml` playbook

```bash
# Provision VM first
ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml --limit semaphore-01

# Deploy Semaphore
ansible-playbook -i inventory/hosts.yml playbooks/deploy-semaphore.yml
```

## Post-Installation

After successful deployment:

1. **Access Web Interface**: Navigate to `http://your-server-ip:3000`
2. **Create Admin User**: Set up your first admin user account
3. **Configure Projects**: Create your first project and inventory
4. **Add Playbooks**: Upload or create your Ansible playbooks
5. **Set up Automation**: Configure your first automation tasks

## File Structure

```
/opt/semaphore/                    # Semaphore installation directory
├── bin/
│   ├── semaphore                  # Semaphore binary
│   └── backup.sh                  # Backup script
├── deployment-info.txt            # Deployment information

/etc/semaphore/                    # Configuration directory
├── config.json                    # Semaphore configuration
└── semaphore.env                  # Environment variables

/var/lib/semaphore/                # Data directory
/var/log/semaphore/                # Log directory
├── backup.log                     # Backup logs

/opt/semaphore-backups/            # Backup directory
└── semaphore_backup_*.sql.gz      # Database backups
```

## Service Management

```bash
# Check status
sudo systemctl status semaphore

# Start service
sudo systemctl start semaphore

# Stop service
sudo systemctl stop semaphore

# Restart service
sudo systemctl restart semaphore

# View logs
sudo journalctl -u semaphore -f
```

## Backup Management

- **Automatic Backups**: Daily at 2:00 AM
- **Backup Location**: `/opt/semaphore-backups/`
- **Retention**: Configurable (default 30 days)
- **Manual Backup**: Run `/opt/semaphore/bin/backup.sh`

## Security Considerations

1. **Change Default Passwords**: Update all default passwords in vault files
2. **Encryption Key**: Change the access key encryption key
3. **Firewall**: UFW is configured by default
4. **SSL/TLS**: Consider setting up reverse proxy with SSL
5. **Regular Updates**: Keep Semaphore updated to latest version

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check MySQL service status: `sudo systemctl status mysql`
   - Verify database credentials in configuration
   - Check firewall rules

2. **Service Won't Start**
   - Check logs: `sudo journalctl -u semaphore`
   - Verify configuration file syntax
   - Check file permissions

3. **Web Interface Not Accessible**
   - Check if service is running: `sudo systemctl status semaphore`
   - Verify port is open: `sudo ufw status`
   - Check if port is listening: `sudo netstat -tlnp | grep 3000`

### Log Locations

- **Service Logs**: `sudo journalctl -u semaphore`
- **Backup Logs**: `/var/log/semaphore/backup.log`
- **Application Logs**: `/var/log/semaphore/`

## License

MIT

## Author Information

Created for Proxmox Homelab automation.
