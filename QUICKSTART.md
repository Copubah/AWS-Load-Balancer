# Quick Start Guide

## Prerequisites Check

Before deploying, ensure you have:

```bash
# Check Terraform installation
terraform version

# Check AWS CLI installation and configuration
aws --version
aws sts get-caller-identity
```

## Deploy in 3 Steps (Using Deployment Script)

### 1. Navigate to Project
```bash
cd aws-alb-terraform
```

### 2. Run Deployment Script
```bash
./deploy.sh --deploy
```

The script will:
- Check prerequisites (Terraform, AWS CLI, credentials)
- Initialize Terraform
- Validate configuration
- Create deployment plan
- Ask for confirmation
- Deploy infrastructure

### 3. Access Your Application

After deployment (2-3 minutes), the script shows the ALB DNS automatically.

Test with curl:
```bash
curl http://$(terraform output -raw alb_dns_name)
```

## Alternative: Manual Deployment (5 Steps)

### 1. Navigate to Project
```bash
cd aws-alb-terraform
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. (Optional) Customize Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred settings
```

### 4. Deploy Infrastructure
```bash
terraform apply
```

Review the plan and type `yes` to confirm.

### 5. Access Your Application

After deployment (2-3 minutes), get the ALB DNS:

```bash
terraform output alb_dns_name
```

Open the URL in your browser or test with curl:

```bash
curl http://$(terraform output -raw alb_dns_name)
```

## What Gets Created

- 1 VPC with 2 public subnets across 2 AZs
- 1 Internet Gateway
- 1 Application Load Balancer
- 1 Target Group
- 1 Auto Scaling Group (2-4 EC2 instances)
- 2 Security Groups (ALB and EC2)
- 1 Launch Template with Nginx

## Estimated Costs

- EC2 t2.micro: Free Tier eligible (750 hours/month)
- ALB: ~$16-20/month
- Data transfer: Variable

## Cleanup

### Using Destroy Script (Recommended)
```bash
./destroy.sh
```

### Using Deployment Script
```bash
./deploy.sh --destroy
```

### Manual Terraform Command
```bash
terraform destroy
```

Type `yes` to confirm deletion.

## Troubleshooting

Issue: "Error: No valid credential sources found"
- Solution: Configure AWS CLI with `aws configure`

Issue: "Error: creating EC2 Launch Template: UnauthorizedOperation"
- Solution: Ensure your AWS user has appropriate IAM permissions

Issue: Instances showing unhealthy in target group
- Solution: Wait 2-3 minutes for user data script to complete
- Check: `aws ec2 describe-instances --filters "Name=tag:Name,Values=web-app-asg-instance"`

## Next Steps

- Add HTTPS support with ACM certificate
- Implement private subnets for enhanced security
- Add RDS database in private subnet
- Configure CloudWatch alarms for monitoring
- Set up CI/CD pipeline for automated deployments
