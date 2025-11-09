#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE="plan.out"

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        echo "Install from: https://www.terraform.io/downloads"
        exit 1
    fi
    print_success "Terraform installed: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        echo "Install from: https://aws.amazon.com/cli/"
        exit 1
    fi
    print_success "AWS CLI installed: $(aws --version | cut -d' ' -f1 | cut -d'/' -f2)"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured"
        echo "Run: aws configure"
        exit 1
    fi
    
    local aws_account=$(aws sts get-caller-identity --query Account --output text)
    local aws_user=$(aws sts get-caller-identity --query Arn --output text | cut -d'/' -f2)
    print_success "AWS credentials configured"
    print_info "Account: $aws_account"
    print_info "User: $aws_user"
}

initialize_terraform() {
    print_header "Initializing Terraform"
    
    cd "$SCRIPT_DIR"
    
    if [ -d ".terraform" ]; then
        print_warning "Terraform already initialized, reinitializing..."
        terraform init -upgrade
    else
        terraform init
    fi
    
    print_success "Terraform initialized"
}

validate_configuration() {
    print_header "Validating Configuration"
    
    terraform fmt -recursive -check &> /dev/null || {
        print_warning "Code formatting issues found, fixing..."
        terraform fmt -recursive
    }
    
    terraform validate
    print_success "Configuration is valid"
}

create_plan() {
    print_header "Creating Deployment Plan"
    
    terraform plan -out="$PLAN_FILE"
    
    print_success "Plan created: $PLAN_FILE"
    print_info "Review the plan above before applying"
}

apply_plan() {
    print_header "Applying Infrastructure Changes"
    
    if [ ! -f "$PLAN_FILE" ]; then
        print_error "Plan file not found. Run with --plan first"
        exit 1
    fi
    
    terraform apply "$PLAN_FILE"
    
    # Clean up plan file
    rm -f "$PLAN_FILE"
    
    print_success "Infrastructure deployed successfully"
}

show_outputs() {
    print_header "Deployment Outputs"
    
    terraform output
    
    echo ""
    print_info "Access your application at:"
    local alb_dns=$(terraform output -raw alb_dns_name 2>/dev/null || echo "N/A")
    echo -e "${GREEN}http://$alb_dns${NC}"
    
    echo ""
    print_warning "Note: It may take 2-3 minutes for instances to become healthy"
    print_info "Test with: curl http://$alb_dns"
}

destroy_infrastructure() {
    print_header "Destroying Infrastructure"
    
    print_warning "This will destroy all resources created by Terraform"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Destruction cancelled"
        exit 0
    fi
    
    terraform destroy
    
    print_success "Infrastructure destroyed"
}

show_help() {
    cat << EOF
AWS ALB Terraform Deployment Script

Usage: ./deploy.sh [OPTION]

Options:
    --check         Check prerequisites only
    --init          Initialize Terraform
    --validate      Validate Terraform configuration
    --plan          Create deployment plan
    --apply         Apply the deployment plan
    --deploy        Full deployment (init + validate + plan + apply)
    --output        Show deployment outputs
    --destroy       Destroy all infrastructure
    --help          Show this help message

Examples:
    ./deploy.sh --deploy        # Full deployment
    ./deploy.sh --plan          # Create plan only
    ./deploy.sh --apply         # Apply existing plan
    ./deploy.sh --destroy       # Destroy infrastructure

EOF
}

# Main script logic
main() {
    case "${1:-}" in
        --check)
            check_prerequisites
            ;;
        --init)
            check_prerequisites
            initialize_terraform
            ;;
        --validate)
            check_prerequisites
            validate_configuration
            ;;
        --plan)
            check_prerequisites
            initialize_terraform
            validate_configuration
            create_plan
            ;;
        --apply)
            check_prerequisites
            apply_plan
            show_outputs
            ;;
        --deploy)
            check_prerequisites
            initialize_terraform
            validate_configuration
            create_plan
            
            echo ""
            read -p "Do you want to apply this plan? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                apply_plan
                show_outputs
            else
                print_info "Deployment cancelled. Plan saved to $PLAN_FILE"
                print_info "Run './deploy.sh --apply' to apply later"
            fi
            ;;
        --output)
            show_outputs
            ;;
        --destroy)
            check_prerequisites
            destroy_infrastructure
            ;;
        --help|"")
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
