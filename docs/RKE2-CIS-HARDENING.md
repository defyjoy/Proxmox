# RKE2 CIS Hardening Guide

## 🔒 Overview

This guide explains how to deploy RKE2 with CIS (Center for Internet Security) hardening enabled for compliance with security benchmarks.

## 🐛 Common Issues & Solutions

### Issue 1: Invalid CIS Profile Value

**Error:**
```
time="2025-10-12T12:22:04Z" level=fatal msg="invalid value provided for --profile flag"
```

**Root Cause:**
The CIS profile value must match your RKE2 version:
- RKE2 < 1.25: Use `"cis-1.6"`
- RKE2 1.25.x - 1.29.x: Use `"cis-1.23"`
- RKE2 1.30+: Use `"cis"`

**Solution:**
Check your RKE2 version in `defaults/main.yml`:
```yaml
rke2_version: v1.31.13+rke2r1  # Version 1.31.x
```

Then set the correct CIS profile:
```yaml
rke2_cis_profile: "cis"  # Correct for v1.31.x (1.30+)
```

### Issue 2: Unknown Ingress Controller Flag

**Warning:**
```
Unknown flag --ingress-controller found in config.yaml, skipping
```

**Root Cause:**
`--ingress-controller` is not a valid RKE2 configuration flag. It's an Ansible role option that gets processed by the role, not passed directly to RKE2.

**Solution:**
Use the correct value:
```yaml
# Use the role's default
rke2_ingress_controller: ingress-nginx

# Or to disable ingress completely, use:
rke2_disable:
  - rke2-ingress-nginx
```

## ⚙️ Correct CIS Configuration

### For RKE2 v1.31.13 (Current Version)

```yaml
# defaults/main.yml

# RKE2 version
rke2_version: v1.31.13+rke2r1

# CIS Profile - MUST match version
rke2_cis_profile: "cis"

# Ingress Controller (role option, not RKE2 flag)
rke2_ingress_controller: ingress-nginx

# To disable components (if needed)
rke2_disable: []
  # - rke2-ingress-nginx  # Uncomment to disable ingress
```

### Version-Specific CIS Profiles

| RKE2 Version | CIS Profile Value | CIS Benchmark |
|--------------|-------------------|---------------|
| < 1.25 | `"cis-1.6"` | CIS Kubernetes Benchmark v1.6 |
| 1.25.x - 1.29.x | `"cis-1.23"` | CIS Kubernetes Benchmark v1.23 |
| 1.30+ | `"cis"` | Latest CIS Benchmark |

## 🔐 CIS Hardening Requirements

When CIS profile is enabled, RKE2 applies additional security hardening:

### 1. Pod Security Standards

CIS profile enables Pod Security Admission:
```yaml
# Automatically configured by CIS profile
pod-security: "restricted"
```

### 2. File Permissions

CIS enforces strict file permissions:
- etcd data: `700`
- kubelet config: `644`
- kubeconfig files: `600`

### 3. Network Policies

Network policies should be enforced:
```yaml
# Add to your workloads
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 4. Service Account Token Automation

CIS requires disabling automatic service account token mounting:
```yaml
# In your pod specs
automountServiceAccountToken: false
```

### 5. Audit Logging

CIS profile enables comprehensive audit logging:
```yaml
# Automatically enabled by CIS profile
audit-log-path: /var/lib/rancher/rke2/server/logs/audit.log
audit-log-maxage: 30
audit-log-maxbackup: 10
audit-log-maxsize: 100
```

## 📝 Complete CIS Configuration Example

```yaml
# defaults/main.yml - CIS Hardened Configuration

# Version and CIS Profile (MUST MATCH!)
rke2_version: v1.31.13+rke2r1
rke2_cis_profile: "cis"

# Cluster token (change to secure value)
rke2_token: "{{ vault_rke2_token }}"

# High Availability (recommended for production)
rke2_ha_mode: true
rke2_ha_mode_keepalived: true
rke2_api_ip: "192.168.68.99"

# CNI (Canal is CIS compliant)
rke2_cni: [canal]

# Ingress (keep default or disable if using external ingress)
rke2_ingress_controller: ingress-nginx

# Components to disable (optional)
rke2_disable: []

# Server taints (recommended for masters)
rke2_server_node_taints:
  - 'CriticalAddonsOnly=true:NoExecute'
  - 'node-role.kubernetes.io/control-plane:NoSchedule'

# Pod security configuration (enforced by CIS)
# These are automatically set by CIS profile:
# - admission-control-config-file
# - pod-security-admission-config-file

# SELinux (recommended for CIS on RHEL-based systems)
rke2_selinux: false  # Set to true if using RHEL/Rocky/Alma
```

## 🚀 Deployment with CIS Profile

### 1. Update Configuration

```bash
nano defaults/main.yml
```

Ensure:
- `rke2_cis_profile` matches your RKE2 version
- `rke2_token` is changed from default
- `rke2_ingress_controller` is not set to "none"

### 2. Deploy Cluster

```bash
# Remove old installation if it failed
task rke2-remove

# Deploy with CIS hardening
task rke2
```

### 3. Verify CIS Profile

```bash
# SSH to master node
ssh root@192.168.68.100

# Check RKE2 server arguments
ps aux | grep rke2

# Should see: --profile=cis

# Check logs
journalctl -u rke2-server -f
```

## 🔍 CIS Compliance Verification

### Check Pod Security

```bash
# On master node
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# Verify Pod Security Standards
kubectl get pss -A

# Check audit logs
ls -la /var/lib/rancher/rke2/server/logs/audit.log
```

### Run CIS Benchmark Scan

```bash
# Install kube-bench
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

# View results
kubectl logs job/kube-bench
```

## 📋 CIS Hardening Checklist

Before deploying with CIS:

- [ ] RKE2 version defined
- [ ] CIS profile matches version (e.g., `"cis-1.23"` for v1.25.x)
- [ ] Cluster token changed from default
- [ ] Ingress controller properly configured
- [ ] HA mode enabled (production)
- [ ] Server node taints configured
- [ ] SELinux configured (if applicable)
- [ ] Network policies planned
- [ ] Pod Security Standards understood
- [ ] Audit logging location planned

After deployment:

- [ ] CIS profile active (check logs)
- [ ] Pods starting correctly
- [ ] Network policies applied
- [ ] Audit logs generated
- [ ] kube-bench scan passed
- [ ] Application workloads tested

## 🐛 Troubleshooting

### RKE2 Server Won't Start

**Check logs:**
```bash
journalctl -u rke2-server -f
```

**Common issues:**
1. Wrong CIS profile value → Update to match version
2. Invalid ingress setting → Use role's default or disable via `rke2_disable`
3. Missing kernel modules → Install required modules

### Pods Stuck in Pending

**CIS enforces Pod Security:**
```bash
# Check pod security violations
kubectl describe pod <pod-name>

# Common fix: Add security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

### Network Policies Blocking Traffic

**CIS doesn't create policies, but you should:**
```bash
# Create namespace-specific policies
kubectl apply -f network-policy.yaml

# Test connectivity
kubectl run test --image=busybox -- sleep 3600
kubectl exec test -- wget -O- http://service
```

## 📚 Additional Resources

- [RKE2 CIS Hardening Guide](https://docs.rke2.io/security/hardening_guide)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [RKE2 Security Documentation](https://docs.rke2.io/security/overview)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)

## 🔄 Upgrading RKE2 with CIS

When upgrading, update both version and CIS profile:

```yaml
# Upgrading from v1.25.3 to v1.31.13
# Before:
rke2_version: v1.25.3+rke2r1
rke2_cis_profile: "cis-1.23"

# After:
rke2_version: v1.31.13+rke2r1
rke2_cis_profile: "cis"  # New format for 1.30+
```

Then run:
```bash
task rke2  # Role handles rolling upgrade
```

## ⚠️ Important Notes

1. **Always match CIS profile to RKE2 version** - Mismatched values cause fatal errors
2. **CIS adds security constraints** - Some workloads may need updates
3. **Test before production** - CIS can break non-compliant applications
4. **Document exceptions** - If you must deviate from CIS, document why
5. **Regular scans** - Run kube-bench regularly to verify compliance

---

**With proper CIS configuration, your cluster will be hardened and compliant! 🔒**

