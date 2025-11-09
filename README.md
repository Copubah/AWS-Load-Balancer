# AWS Scalable Web Application with Terraform

## Overview

This project deploys a highly available, scalable web application on AWS using Terraform. It provisions a VPC with multi-AZ architecture, an Application Load Balancer, and an Auto Scaling Group of EC2 instances running Nginx.

## Architecture Diagram

```
                                    Internet
                                       |
                                       |
                            +----------v-----------+
                            |  Application Load   |
                            |     Balancer        |
                            |   (Public Subnets)  |
                            +----------+----------+
                                       |
                    +------------------+------------------+
                    |                                     |
         +----------v-----------+              +----------v-----------+
         |   Auto Scaling Group |              |   Auto Scaling Group |
         |    EC2 (Nginx)       |              |    EC2 (Nginx)       |
         |  Availability Zone A |              |  Availability Zone B |
         |   (Public Subnet)    |              |   (Public Subnet)    |
         +----------------------+              +----------------------+
                    |                                     |
                    +------------------+------------------+
                                       |
                            +----------v-----------+
                            |        VPC           |
                            |   CIDR: 10.0.0.0/16  |
                            +----------------------+
```

## Features

- Multi-AZ Deployment: Resources distributed across two availability zones for high availability
- Auto Scaling: Automatically adjusts EC2 instance count based on demand
- Load Balancing: ALB distributes traffic evenly across healthy instances
- Modular Design: Reusable Terraform modules for VPC, EC2, ALB, and Security Groups
- Security: Properly configured security groups with least privilege access
- Infrastructure as Code: Complete automation using Terraform

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- SSH key pair created in your AWS region (optional, for EC2 access)

## Setup Instructions

### Option 1: Using Deployment Script (Recommended)

The automated deployment script handles all steps with validation and error checking.

```bash
cd aws-alb-terraform

# Full deployment with interactive confirmation
./deploy.sh --deploy

# Or step by step
./deploy.sh --check      # Check prerequisites
./deploy.sh --plan       # Create deployment plan
./deploy.sh --apply      # Apply the plan
./deploy.sh --output     # Show outputs
```

### Option 2: Manual Terraform Commands

#### 1. Navigate to Project

```bash
cd aws-alb-terraform
```

#### 2. Initialize Terraform

```bash
terraform init
```

#### 3. (Optional) Customize Configuration

Edit `terraform.tfvars` (create if needed):

```hcl
aws_region    = "us-east-1"
project_name  = "my-web-app"
instance_type = "t2.micro"
min_size      = 2
max_size      = 4
desired_size  = 2
```

#### 4. Plan Deployment

```bash
terraform plan
```

#### 5. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.

#### 6. Access Your Application

After deployment completes, Terraform will output the ALB DNS name:

```bash
alb_dns_name = "my-web-app-alb-1234567890.us-east-1.elb.amazonaws.com"
```

Open this URL in your browser to see the application.

## Directory Structure

```
aws-alb-terraform/
├── deploy.sh               # Automated deployment script
├── destroy.sh              # Automated destruction script
├── main.tf                 # Root module - orchestrates all resources
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── provider.tf             # AWS provider configuration
├── user_data.sh            # EC2 initialization script
├── terraform.tfvars.example # Example configuration
├── .gitignore              # Git ignore rules
├── modules/
│   ├── vpc/
│   │   ├── main.tf        # VPC, subnets, IGW, route tables
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── main.tf        # Security groups for ALB and EC2
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf        # Application Load Balancer, target group, listener
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/
│       ├── main.tf        # Launch template, Auto Scaling Group
│       ├── variables.tf
│       └── outputs.tf
├── README.md               # Complete documentation
└── QUICKSTART.md           # Quick start guide
```

## Deployment Scripts

### deploy.sh

Automated deployment script with the following features:
- Prerequisites validation (Terraform, AWS CLI, credentials)
- Terraform initialization and validation
- Interactive deployment with confirmation
- Color-coded output for better readability
- Error handling and rollback support

Available Commands:
```bash
./deploy.sh --check      # Check prerequisites only
./deploy.sh --init       # Initialize Terraform
./deploy.sh --validate   # Validate configuration
./deploy.sh --plan       # Create deployment plan
./deploy.sh --apply      # Apply existing plan
./deploy.sh --deploy     # Full deployment (recommended)
./deploy.sh --output     # Show deployment outputs
./deploy.sh --destroy    # Destroy infrastructure
./deploy.sh --help       # Show help
```

### destroy.sh

Safe destruction script with:
- Double confirmation prompts
- Clear warning about resource deletion
- Automatic cleanup of all resources

### Makefile

For developers who prefer Make:
```bash
make help        # Show all available targets
make deploy      # Full deployment
make plan        # Create deployment plan
make destroy     # Destroy infrastructure
make format      # Format Terraform code
make clean       # Clean Terraform files
```

## How It Works

### VPC Module
Creates a Virtual Private Cloud with:
- CIDR block: 10.0.0.0/16
- Public subnets in two availability zones
- Internet Gateway for public internet access
- Route tables configured for internet routing

### Security Module
Defines security groups:
- ALB Security Group: Allows HTTP (port 80) from anywhere
- EC2 Security Group: Allows HTTP from ALB only, SSH from anywhere (optional)

### ALB Module
Provisions:
- Application Load Balancer in public subnets
- Target group for EC2 instances
- HTTP listener on port 80
- Health checks to monitor instance status

### EC2 Module
Creates:
- Launch template with Amazon Linux 2 AMI
- User data script to install and start Nginx
- Auto Scaling Group with desired capacity
- Attachment to ALB target group

## Outputs

After successful deployment, you'll see:

- `alb_dns_name`: The DNS name to access your application
- `vpc_id`: The ID of the created VPC
- `public_subnet_ids`: List of public subnet IDs
- `asg_name`: Name of the Auto Scaling Group

## Testing

1. Access the Application:
   ```bash
   curl http://<alb_dns_name>
   ```

2. Verify Load Balancing:
   Refresh the page multiple times. The ALB distributes requests across instances.

3. Check Auto Scaling:
   ```bash
   aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names <asg_name>
   ```

## Cleanup Instructions

### Option 1: Using Destroy Script (Recommended)

```bash
./destroy.sh
```

The script will prompt for double confirmation before destroying resources.

### Option 2: Using Deployment Script

```bash
./deploy.sh --destroy
```

### Option 3: Manual Terraform Command

```bash
terraform destroy
```

Type `yes` when prompted to confirm.

## Cost Considerations

This setup uses:
- EC2 t2.micro instances (Free Tier eligible)
- Application Load Balancer (~$16-20/month)
- Data transfer costs

Remember to destroy resources when not in use.

## Customization

Modify variables in `variables.tf` or create `terraform.tfvars`:
- Change instance types
- Adjust Auto Scaling parameters
- Modify CIDR blocks
- Add additional availability zones

## Troubleshooting

Issue: Instances unhealthy in target group
- Check security group rules
- Verify user data script executed successfully
- Review EC2 instance logs

Issue: Cannot access ALB DNS
- Wait 2-3 minutes for instances to become healthy
- Verify ALB is in "active" state
- Check security group allows port 80

## Additional Documentation

- QUICKSTART.md - Get started in 3 steps
- .github-workflows-example.yml - CI/CD template for GitHub Actions

## License

This project is open source and available for educational purposes.
