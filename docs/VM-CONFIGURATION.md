# VM Configuration Guide

This document explains how to configure CPU cores, memory, and disk resources for your Proxmox VMs in the RKE2 cluster.

## Configuration Files

VM resource configuration is managed through the following files:

- `group_vars/all/vars.yml` - Main configuration variables
- `playbooks/provision-vms.yml` - VM provisioning playbook

## Resource Configuration

### CPU Cores

Configure the number of CPU cores for different node types:

```yaml
# Master nodes configuration
vm_master_cores: 4      # Master nodes get 4 CPU cores

# Worker nodes configuration  
vm_worker_cores: 2      # Worker nodes get 2 CPU cores
```

### Memory Configuration

Configure RAM allocation for different node types:

```yaml
# Memory configuration (in MB)
vm_master_memory: 8192  # Master nodes get 8GB RAM
vm_worker_memory: 4096  # Worker nodes get 4GB RAM
```

### Disk Configuration

Configure disk size for different node types:

```yaml
# Disk configuration (in GB)
vm_master_disk: 50      # Master nodes get 50GB disk
vm_worker_disk: 32      # Worker nodes get 32GB disk
```

## Default Configuration

The current default configuration provides:

| Node Type | CPU Cores | RAM | Disk |
|-----------|-----------|-----|------|
| Master    | 4         | 8GB | 50GB |
| Worker    | 2         | 4GB | 32GB |

## Customizing Configuration

To modify the VM resources:

1. **Edit the configuration file:**
   ```bash
   nano group_vars/all/vars.yml
   ```

2. **Update the values** for the resources you want to change:
   ```yaml
   # Example: Increase master node resources
   vm_master_cores: 6      # 6 CPU cores
   vm_master_memory: 16384 # 16GB RAM
   vm_master_disk: 100     # 100GB disk
   ```

3. **Provision new VMs** with the updated configuration:
   ```bash
   task provision
   ```

## Resource Recommendations

### Minimum Requirements

| Node Type | CPU Cores | RAM | Disk |
|-----------|-----------|-----|------|
| Master    | 2         | 4GB | 20GB |
| Worker    | 1         | 2GB | 20GB |

### Recommended for Production

| Node Type | CPU Cores | RAM | Disk |
|-----------|-----------|-----|------|
| Master    | 4         | 8GB | 50GB |
| Worker    | 2         | 4GB | 32GB |

### High-Performance Setup

| Node Type | CPU Cores | RAM | Disk |
|-----------|-----------|-----|------|
| Master    | 8         | 16GB| 100GB|
| Worker    | 4         | 8GB | 50GB |

## Verification

After provisioning, you can verify the resource allocation:

```bash
# Check VM status and resources
task ping

# View detailed VM information
ssh -i ~/.ssh/proxmox root@192.168.68.100
nproc          # Check CPU cores
free -h        # Check memory
df -h          # Check disk usage
```

## Notes

- **CPU Cores**: More cores improve parallel processing and reduce scheduling contention
- **Memory**: Sufficient RAM is crucial for Kubernetes workloads and container operations
- **Disk**: Adequate disk space is needed for container images, logs, and persistent volumes
- **Storage**: Ensure your Proxmox storage has sufficient space for all VMs
- **Network**: Consider network bandwidth requirements for your workloads

## Troubleshooting

If VMs fail to provision with the configured resources:

1. **Check Proxmox storage space**
2. **Verify host has sufficient resources**
3. **Review Proxmox logs** for resource allocation errors
4. **Reduce resource requirements** if host is resource-constrained

For more information, see the main [README.md](../README.md) and [SETUP.md](SETUP.md) files.
