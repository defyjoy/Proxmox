# Provision VMs Role

This role provisions VMs in Proxmox by cloning from a template (default: template ID 9000).

## Requirements

- `community.general` Ansible collection
- Proxmox VE cluster with API access
- VM template configured with cloud-init support

## Installation

Install the required collection:

```bash
ansible-galaxy collection install community.general
```

## Role Variables

### Proxmox Connection
- `proxmox_host`: Proxmox host/IP (default: `proxmox.local`)
- `proxmox_api_user`: API user (default: `root@pam`)
- `proxmox_api_password`: API password (optional if using token)
- `proxmox_api_token_id`: API token ID (optional)
- `proxmox_api_token_secret`: API token secret (optional)
- `proxmox_node`: Proxmox node name (default: `pve`)

### VM Template
- `proxmox_template_id`: Template VM ID to clone from (default: `9000`)
- `proxmox_template_storage`: Storage for template (default: `local-lvm`)

### VM Configuration
- `vm_cores`: Number of CPU cores (default: `2`)
- `vm_memory`: Memory in MB (default: `4096`)
- `vm_disk_size`: Disk size in GB (default: `32`)
- `vm_storage`: Storage for VM disks (default: `local-lvm`)
- `vm_network_bridge`: Network bridge (default: `vmbr0`)
- `vm_network_model`: Network model (default: `virtio`)

### Cloud-init Settings
- `vm_ciuser`: Cloud-init user (default: `ubuntu`)
- `vm_cipassword`: Cloud-init password (optional)
- `vm_sshkeys`: SSH public keys (optional)
- `vm_nameserver`: DNS nameserver (default: `8.8.8.8`)
- `vm_searchdomain`: DNS search domain (default: `local`)

### VM Identification
- `vm_name`: VM name (required per host)
- `vm_id`: VM ID (required per host)
- `ansible_host`: IP address for the VM (from inventory)

### Timeouts
- `vm_timeout`: Operation timeout in seconds (default: `300`)
- `vm_startup_delay`: Delay before checking if VM is up (default: `10`)

## Dependencies

None

## Example Playbook

```yaml
---
- name: Provision VMs in Proxmox
  hosts: k8s_cluster
  gather_facts: false
  vars:
    proxmox_host: 192.168.1.100
    proxmox_api_user: automation@pve
    proxmox_api_password: "{{ lookup('env', 'PROXMOX_PASSWORD') }}"
    proxmox_node: pve01
    proxmox_template_id: 9000
    vm_cores: 4
    vm_memory: 8192
    vm_disk_size: 50
  
  tasks:
    - name: Set VM-specific variables
      ansible.builtin.set_fact:
        vm_name: "{{ inventory_hostname }}"
        vm_id: "{{ 200 + groups['k8s_cluster'].index(inventory_hostname) }}"
    
    - name: Provision VM
      ansible.builtin.include_role:
        name: provision-vms
```

## License

MIT

## Author Information

Created for RKE2 Proxmox provisioning

