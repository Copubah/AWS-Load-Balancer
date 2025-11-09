#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_header "AWS Infrastructure Destruction"

echo -e "${RED}WARNING: This will permanently delete all resources!${NC}"
echo ""
echo "Resources to be destroyed:"
echo "  - VPC and all subnets"
echo "  - Application Load Balancer"
echo "  - Auto Scaling Group and EC2 instances"
echo "  - Security Groups"
echo "  - All associated resources"
echo ""

read -p "Type 'destroy' to confirm: " confirm

if [ "$confirm" != "destroy" ]; then
    print_error "Destruction cancelled"
    exit 0
fi

echo ""
read -p "Are you absolutely sure? (yes/no): " final_confirm

if [ "$final_confirm" != "yes" ]; then
    print_error "Destruction cancelled"
    exit 0
fi

print_header "Destroying Infrastructure"

terraform destroy -auto-approve

print_success "All resources have been destroyed"
print_warning "Remember to check AWS Console to verify all resources are deleted"
