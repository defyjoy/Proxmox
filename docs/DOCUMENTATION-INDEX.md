# Documentation Index

All project documentation is organized in this `docs/` folder for easy access and maintenance.

## 📚 Quick Navigation

### 🚀 Getting Started

1. **[QUICKSTART.md](QUICKSTART.md)** - Fast-track deployment guide
   - Quick installation steps
   - Essential commands
   - Minimal configuration

2. **[SETUP.md](SETUP.md)** - Complete setup instructions
   - Detailed prerequisites
   - Step-by-step configuration
   - Troubleshooting common issues

### 🔐 Security & Authentication

3. **[AUTHENTICATION.md](AUTHENTICATION.md)** - Security and authentication setup
   - SSH key configuration
   - Proxmox API tokens
   - Best security practices

4. **[VAULT.md](VAULT.md)** - Ansible Vault management
   - Creating encrypted vaults
   - Managing credentials
   - Vault commands reference

### ☸️ Kubernetes / RKE2

5. **[RKE2-QUICKSTART.md](RKE2-QUICKSTART.md)** - RKE2 quick start
   - Fast deployment
   - Essential RKE2 commands
   - Quick verification

6. **[RKE2-DEPLOYMENT.md](RKE2-DEPLOYMENT.md)** - Complete RKE2 deployment guide
   - Comprehensive deployment instructions
   - Configuration options
   - Customization examples
   - Advanced features

7. **[RKE2-SETUP.md](RKE2-SETUP.md)** - RKE2 setup and prerequisites
   - Role installation
   - Pre-flight checklist
   - Verification steps

8. **[RKE2-IMPLEMENTATION-SUMMARY.md](RKE2-IMPLEMENTATION-SUMMARY.md)** - Implementation details
   - Architecture overview
   - Design decisions
   - Component breakdown
   - Technical reference

9. **[KUBECONFIG-USAGE.md](KUBECONFIG-USAGE.md)** - Kubeconfig guide
   - Automatic download
   - Multiple usage methods
   - kubectl configuration
   - Troubleshooting access

### 🔧 Maintenance & Troubleshooting

10. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Debug and common issues
    - Common problems and solutions
    - Diagnostic commands
    - Error resolution

11. **[FIXED-README.md](FIXED-README.md)** - Recent fixes and updates
    - Latest bug fixes
    - Implementation corrections
    - Update notes

## 📖 Documentation by Topic

### For First-Time Users
1. Read [QUICKSTART.md](QUICKSTART.md) for fast setup
2. Check [AUTHENTICATION.md](AUTHENTICATION.md) for security setup
3. Review [VAULT.md](VAULT.md) for credential management
4. Follow [RKE2-QUICKSTART.md](RKE2-QUICKSTART.md) to deploy Kubernetes

### For Detailed Setup
1. Start with [SETUP.md](SETUP.md) for complete instructions
2. Read [RKE2-SETUP.md](RKE2-SETUP.md) for RKE2 prerequisites
3. Follow [RKE2-DEPLOYMENT.md](RKE2-DEPLOYMENT.md) for full deployment
4. Use [KUBECONFIG-USAGE.md](KUBECONFIG-USAGE.md) to access your cluster

### For Troubleshooting
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first
2. Review [FIXED-README.md](FIXED-README.md) for recent fixes
3. Consult specific deployment guides for detailed issues

### For Understanding the System
1. Read [RKE2-IMPLEMENTATION-SUMMARY.md](RKE2-IMPLEMENTATION-SUMMARY.md) for architecture
2. Review playbooks in `../playbooks/`
3. Check `../defaults/main.yml` for all configuration options

## 📁 File Organization

```
docs/
├── AUTHENTICATION.md                 # Security setup
├── FIXED-README.md                   # Recent fixes
├── KUBECONFIG-USAGE.md               # Kubectl access guide
├── QUICKSTART.md                     # Quick start guide
├── RKE2-DEPLOYMENT.md                # Complete RKE2 guide
├── RKE2-IMPLEMENTATION-SUMMARY.md    # Architecture details
├── RKE2-QUICKSTART.md                # RKE2 quick start
├── RKE2-SETUP.md                     # RKE2 prerequisites
├── SETUP.md                          # Complete setup
├── TROUBLESHOOTING.md                # Debug guide
└── VAULT.md                          # Vault management
```

## 🎯 Quick Reference by Use Case

### "I want to deploy quickly"
→ [QUICKSTART.md](QUICKSTART.md) + [RKE2-QUICKSTART.md](RKE2-QUICKSTART.md)

### "I want to understand everything first"
→ [SETUP.md](SETUP.md) + [RKE2-DEPLOYMENT.md](RKE2-DEPLOYMENT.md)

### "I'm having issues"
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md) + [FIXED-README.md](FIXED-README.md)

### "I need to configure security"
→ [AUTHENTICATION.md](AUTHENTICATION.md) + [VAULT.md](VAULT.md)

### "I can't access my cluster"
→ [KUBECONFIG-USAGE.md](KUBECONFIG-USAGE.md)

### "I want to understand the architecture"
→ [RKE2-IMPLEMENTATION-SUMMARY.md](RKE2-IMPLEMENTATION-SUMMARY.md)

## 🔗 External Resources

- **Main README**: [../README.md](../README.md) - Project overview and quick commands
- **Taskfile**: [../Taskfile.yml](../Taskfile.yml) - All available commands
- **Configuration**: [../defaults/main.yml](../defaults/main.yml) - RKE2 settings (350+ variables)
- **Inventory**: [../inventory/hosts.yml](../inventory/hosts.yml) - VM definitions

## 📝 Documentation Standards

All documentation in this project follows these principles:

- ✅ **Clear Structure** - Easy to navigate with headers and sections
- ✅ **Code Examples** - Practical, copy-paste ready commands
- ✅ **Troubleshooting** - Common issues and solutions included
- ✅ **Cross-References** - Links between related documents
- ✅ **Up-to-Date** - Reflects current implementation

## 🤝 Contributing

When adding new documentation:

1. Place all `.md` files in this `docs/` folder (except README.md)
2. Update this index file with the new document
3. Add cross-references from related documents
4. Follow the existing documentation style
5. Include code examples where applicable

## 📞 Need Help?

1. **Check the documentation** - Most questions are answered here
2. **Run diagnostic commands** - See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. **Review recent fixes** - Check [FIXED-README.md](FIXED-README.md)
4. **Check external resources** - Links in each guide

---

**Last Updated**: October 12, 2025  
**Total Documents**: 11 guides covering all aspects of the project

Happy deploying! 🚀

