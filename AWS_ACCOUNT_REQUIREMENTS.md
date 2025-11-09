# AWS Account Requirements

## Error: Account Does Not Support Creating Load Balancers

If you encounter this error:
```
Error: creating ELBv2 application Load Balancer: operation error Elastic Load Balancing v2: 
CreateLoadBalancer, OperationNotPermitted: This AWS account currently does not support creating 
load balancers. For more information, please contact AWS Support.
```

## Causes

1. **New AWS Account**: Newly created AWS accounts may have restrictions on creating certain resources
2. **Account Limits**: Your account may have reached the limit for load balancers
3. **Service Restrictions**: Some AWS accounts (especially free tier or educational) have service restrictions

## Solutions

### Option 1: Contact AWS Support

1. Go to AWS Support Center: https://console.aws.amazon.com/support/home
2. Create a case with the following details:
   - Subject: "Request to enable Application Load Balancer creation"
   - Service: Elastic Load Balancing
   - Category: Service Limit Increase
   - Description: "Please enable Application Load Balancer creation for my account"

### Option 2: Check Service Quotas

1. Go to AWS Service Quotas console
2. Search for "Elastic Load Balancing"
3. Check your current limits:
   - Application Load Balancers per Region (default: 50)
   - Network Load Balancers per Region (default: 50)

### Option 3: Verify Account Status

1. Ensure your AWS account is fully activated
2. Add a valid payment method
3. Verify your identity if required
4. Wait 24-48 hours after account creation

### Option 4: Use Alternative Architecture

If you cannot create an ALB, consider these alternatives:

#### A. Use Classic Load Balancer (ELB)
- Older but still supported
- May have fewer restrictions
- Update `modules/alb/main.tf` to use `aws_elb` instead

#### B. Use Network Load Balancer (NLB)
- Layer 4 load balancer
- May have different restrictions
- Change `load_balancer_type = "network"`

#### C. Use EC2 with Elastic IP
- Single EC2 instance with public IP
- No load balancing
- Simpler architecture for testing

#### D. Use CloudFront + S3
- For static content
- No EC2 instances needed
- Lower cost

## Checking Your Account Permissions

Run this AWS CLI command to check your account limits:

```bash
aws elbv2 describe-account-limits
```

Check if you can create load balancers:

```bash
aws elbv2 create-load-balancer \
  --name test-alb \
  --subnets subnet-xxxxx subnet-yyyyy \
  --security-groups sg-xxxxx \
  --scheme internet-facing \
  --type application \
  --dry-run
```

## Required IAM Permissions

Ensure your IAM user/role has these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyTargetGroupAttributes"
      ],
      "Resource": "*"
    }
  ]
}
```

## Workaround: Deploy Without ALB

To test the infrastructure without ALB:

1. Comment out the ALB module in `main.tf`:
```hcl
# module "alb" {
#   source = "./modules/alb"
#   ...
# }
```

2. Update EC2 instances to have public IPs
3. Access instances directly via their public IPs

## Timeline

- **Immediate**: Check account status and limits
- **1-2 hours**: AWS Support response (Business/Enterprise support)
- **24-48 hours**: AWS Support response (Basic support)
- **2-5 days**: Account restriction removal

## Alternative: Use Different AWS Account

If you need immediate access:
1. Create a new AWS account
2. Ensure it's fully verified
3. Add payment method
4. Wait 24 hours
5. Try deploying again

## Testing Without Deployment

You can still test the Terraform configuration:

```bash
# Validate syntax
terraform validate

# Check formatting
terraform fmt -check

# Create plan (won't actually deploy)
terraform plan
```

## Contact Information

- AWS Support: https://console.aws.amazon.com/support/home
- AWS Service Quotas: https://console.aws.amazon.com/servicequotas/
- AWS Forums: https://forums.aws.amazon.com/

## Next Steps

1. Contact AWS Support to enable ALB creation
2. While waiting, review and understand the Terraform code
3. Test with `terraform plan` to ensure configuration is correct
4. Once enabled, run `terraform apply` to deploy

## Prevention

For future AWS accounts:
- Fully verify account immediately
- Add payment method
- Request service limit increases proactively
- Wait 24-48 hours before deploying complex infrastructure
