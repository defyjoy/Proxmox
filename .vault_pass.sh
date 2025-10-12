#!/bin/bash
# Vault password retrieval script
# Returns vault password if .vault_pass file exists
# Otherwise returns empty (will prompt)

if [ -f "$(dirname "$0")/.vault_pass" ]; then
    cat "$(dirname "$0")/.vault_pass"
else
    # Return empty - Ansible will prompt
    echo ""
fi

