#!/bin/bash
# Quick setup script for RKE2 Proxmox Provisioner

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== RKE2 Proxmox Provisioner Setup ===${NC}\n"

# Check for required tools
echo "Checking for required tools..."

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $1 found"
        return 0
    else
        echo -e "  ${RED}✗${NC} $1 not found"
        return 1
    fi
}

ALL_FOUND=true
check_command ansible-playbook || ALL_FOUND=false
check_command python3 || ALL_FOUND=false

# Check for task or make
HAS_TASK=false
HAS_MAKE=false
if check_command task; then
    HAS_TASK=true
fi
if check_command make; then
    HAS_MAKE=true
fi

if [ "$HAS_TASK" = false ] && [ "$HAS_MAKE" = false ]; then
    echo -e "\n${YELLOW}Warning: Neither 'task' nor 'make' found. Install one of them:${NC}"
    echo "  Task: https://taskfile.dev/installation/"
    echo "  Make: Usually pre-installed on most systems"
    ALL_FOUND=false
fi

if [ "$ALL_FOUND" = false ]; then
    echo -e "\n${RED}Some required tools are missing. Please install them first.${NC}"
    exit 1
fi

echo -e "\n${GREEN}All required tools found!${NC}\n"

# Install Ansible collections
echo "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "\n${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}Please edit .env file and add your Proxmox credentials${NC}"
else
    echo -e "\n${GREEN}.env file already exists${NC}"
fi

# Display next steps
echo -e "\n${GREEN}=== Setup Complete! ===${NC}\n"
echo "Next steps:"
echo "  1. Create Proxmox API Token:"
echo "     Datacenter -> Permissions -> API Tokens -> Add"
echo ""
echo "  2. Configure authentication:"
echo "     ${YELLOW}export PROXMOX_API_TOKEN_ID='root@pam!provisioner'${NC}"
echo "     ${YELLOW}export PROXMOX_API_TOKEN_SECRET='your-token-secret'${NC}"
echo "     Or edit .env file and run: ${YELLOW}source .env${NC}"
echo ""
echo "  3. Ensure SSH key exists and is configured:"
echo "     ${YELLOW}ls -la ~/.ssh/id_rsa${NC}"
echo "     Add public key to VM template cloud-init"
echo ""
echo "  4. Edit inventory/hosts.yml with your VM IP addresses"
echo "  5. Edit playbooks/provision-vms.yml with your Proxmox settings"
echo ""
echo "Quick commands:"
if [ "$HAS_TASK" = true ]; then
    echo "  ${GREEN}task help${NC}        - Show all available commands"
    echo "  ${GREEN}task cluster${NC}     - Deploy complete cluster"
fi
if [ "$HAS_MAKE" = true ]; then
    echo "  ${GREEN}make help${NC}        - Show all available commands"
    echo "  ${GREEN}make cluster${NC}     - Deploy complete cluster"
fi
echo ""
echo "Happy clustering! 🚀"

