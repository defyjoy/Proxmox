# Inventory Files

This directory contains Ansible inventory files for different deployment scenarios.

## Available Inventories

### `hosts.yml`
- **Purpose**: Main inventory for Kubernetes cluster deployment
- **Groups**: `k8s_cluster`, `masters`, `workers`, `semaphore_servers`
- **Usage**: General infrastructure and RKE2 Kubernetes deployments

### `semaphore.yml`
- **Purpose**: Dedicated inventory for Semaphore CI/CD infrastructure
- **Groups**: 
  - `semaphore_servers` - Main Semaphore application servers
  - `semaphore_databases` - Dedicated database servers
  - `semaphore_agents` - Distributed execution agents
  - `semaphore_loadbalancer` - Load balancer for HA deployments
  - `semaphore_infrastructure` - All Semaphore components
- **Usage**: Semaphore-specific deployments and infrastructure

## Usage Examples

### Kubernetes Cluster Deployment
```bash
# Provision VMs
ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml

# Deploy RKE2
ansible-playbook -i inventory/hosts.yml playbooks/rke2-ansible.yaml
```

### Semaphore Infrastructure Deployment
```bash
# Provision Semaphore infrastructure
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml

# Deploy Semaphore
ansible-playbook -i inventory/semaphore.yml playbooks/deploy-semaphore.yml
```

### Mixed Deployments
```bash
# Use specific inventory for specific tasks
ansible-playbook -i inventory/hosts.yml playbooks/provision-vms.yml --limit k8s_cluster
ansible-playbook -i inventory/semaphore.yml playbooks/provision-semaphore-vms.yml --limit semaphore_servers
```

## Network Layout

### Kubernetes Cluster (hosts.yml)
```
192.168.68.100 - master-01
192.168.68.101 - master-02
192.168.68.102 - master-03
192.168.68.110 - worker-01
192.168.68.111 - worker-02
192.168.68.112 - worker-03
```

### Semaphore Infrastructure (semaphore.yml)
```
192.168.68.120 - semaphore-01 (Primary Server)
192.168.68.121 - semaphore-02 (HA Server)
192.168.68.130 - semaphore-db-01 (Database Server)
192.168.68.140 - semaphore-agent-01 (Agent 1)
192.168.68.141 - semaphore-agent-02 (Agent 2)
192.168.68.150 - semaphore-lb-01 (Load Balancer)
```

## Customization

### Adding New Hosts

1. **Edit appropriate inventory file** (`hosts.yml` or `semaphore.yml`)
2. **Add host configuration** with IP address and any host-specific variables
3. **Update network layout** if needed
4. **Test connectivity** with `ansible -i inventory/filename.yml group_name -m ping`

### Modifying Groups

1. **Add new groups** as needed for your infrastructure
2. **Update group variables** for shared configuration
3. **Modify playbooks** to target new groups if needed

### Environment-Specific Inventories

Create environment-specific inventories:

```bash
# Create production inventory
cp inventory/hosts.yml inventory/production.yml
# Edit production.yml with production IPs and variables

# Create staging inventory
cp inventory/hosts.yml inventory/staging.yml
# Edit staging.yml with staging IPs and variables
```

## Security Notes

- **SSH Keys**: All inventories reference `~/.ssh/proxmox` for SSH access
- **Vault Files**: Sensitive data should be stored in encrypted vault files
- **Network Security**: Consider network segmentation for different environments
- **Access Control**: Limit SSH access to necessary IP ranges

## Best Practices

1. **Separate Inventories**: Use dedicated inventories for different purposes
2. **Group Organization**: Organize hosts into logical groups
3. **Variable Hierarchy**: Use group and host variables appropriately
4. **Documentation**: Keep inventory structure documented
5. **Testing**: Test inventory changes before production use
