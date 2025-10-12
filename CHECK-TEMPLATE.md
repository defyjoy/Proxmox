# How to Find Your Proxmox Template Name

## Quick Check

Your template with ID **9000** needs a NAME, not just an ID for cloning.

## Find Template Name in Proxmox UI

1. **Log into Proxmox web interface**
2. **Navigate to your node** (e.g., pve-01)
3. **Look for VM ID 9000** in the left panel
4. **The NAME is shown** next to the ID

Example display:
```
pve-01
  └─ 9000 (ubuntu-template)  ← This is the name
```

## Find Template Name via CLI

If you have SSH access to Proxmox:

```bash
ssh root@192.168.68.65

# List all VMs/templates
qm list | grep 9000

# Get template details
qm config 9000 | grep name

# Or use pvesh API
pvesh get /nodes/pve-01/qemu/9000/config --output-format=yaml | grep name
```

## Common Template Names

- `ubuntu-template`
- `ubuntu-cloud-template`
- `ubuntu-22.04-template`
- `ubuntu-2204-cloudinit`
- `debian-template`
- `rocky-template`

## Update Configuration

Once you find the name, update:

### File: `playbooks/provision-vms.yml`

```yaml
vars:
  proxmox_template_id: 9000
  proxmox_template_name: "YOUR-ACTUAL-TEMPLATE-NAME"  # ← Change this
```

### File: `roles/provision-vms/defaults/main.yml`

```yaml
proxmox_template_id: 9000
proxmox_template_name: "YOUR-ACTUAL-TEMPLATE-NAME"  # ← Change this
```

## If Template Has No Name

If your template VM has no name set (only ID), you need to set one:

```bash
# In Proxmox web UI:
# 1. Select template (9000)
# 2. Right-click → Rename
# 3. Give it a name like "ubuntu-template"

# Or via CLI:
ssh root@192.168.68.65
qm set 9000 --name ubuntu-template
```

## Test After Update

```bash
# Update the template name in playbook
# Then test:
task provision
```

The clone operation should now work! 🚀

