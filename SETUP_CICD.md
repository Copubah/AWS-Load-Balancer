# CI/CD Setup Guide

## GitHub Actions Workflows

This repository includes two GitHub Actions workflows:

1. **terraform.yml** - Validates, plans, and applies Terraform changes
2. **terraform-destroy.yml** - Manually destroys infrastructure

## Required GitHub Secrets

To enable CI/CD, you need to add AWS credentials as GitHub secrets.

### Step 1: Get AWS Credentials

You need an AWS IAM user with programmatic access and the following permissions:
- EC2 (full access)
- VPC (full access)
- Elastic Load Balancing (full access)
- Auto Scaling (full access)

### Step 2: Add Secrets to GitHub

#### Option 1: Using GitHub CLI

```bash
# Set AWS Access Key ID
gh secret set AWS_ACCESS_KEY_ID

# Set AWS Secret Access Key
gh secret set AWS_SECRET_ACCESS_KEY
```

When prompted, paste your AWS credentials.

#### Option 2: Using GitHub Web Interface

1. Go to your repository: https://github.com/Copubah/AWS-Load-Balancer
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** > **Actions**
4. Click **New repository secret**
5. Add the following secrets:
   - Name: `AWS_ACCESS_KEY_ID`
     Value: Your AWS Access Key ID
   - Name: `AWS_SECRET_ACCESS_KEY`
     Value: Your AWS Secret Access Key

### Step 3: Verify Secrets

```bash
gh secret list
```

You should see:
```
AWS_ACCESS_KEY_ID        Updated YYYY-MM-DD
AWS_SECRET_ACCESS_KEY    Updated YYYY-MM-DD
```

## How CI/CD Works

### On Pull Request
- Validates Terraform syntax
- Runs `terraform fmt -check`
- Runs `terraform validate`
- Creates a plan (does not apply)

### On Push to Main
- Validates Terraform syntax
- Runs `terraform validate`
- Applies infrastructure changes automatically
- Outputs the ALB DNS name

### Manual Destroy
- Go to **Actions** tab
- Select **Terraform Destroy** workflow
- Click **Run workflow**
- Type "destroy" to confirm
- Click **Run workflow** button

## Workflow Files

### .github/workflows/terraform.yml
Main deployment workflow with three jobs:
- `terraform-validate`: Checks syntax and validates configuration
- `terraform-plan`: Creates plan on pull requests
- `terraform-apply`: Applies changes on main branch pushes

### .github/workflows/terraform-destroy.yml
Manual workflow to destroy infrastructure:
- Requires manual confirmation
- Only runs when "destroy" is typed in the input

## Testing the CI/CD

### Test 1: Validation (No AWS Credentials Needed)
```bash
# Make a small change
echo "# Test" >> README.md
git add README.md
git commit -m "test: trigger validation"
git push
```

This will trigger the validation job which doesn't need AWS credentials.

### Test 2: Full Deployment (AWS Credentials Required)
```bash
# Create a feature branch
git checkout -b feature/test-deployment

# Make a change
echo "# Feature test" >> README.md
git add README.md
git commit -m "feat: test deployment"
git push -u origin feature/test-deployment

# Create a pull request
gh pr create --title "Test deployment" --body "Testing CI/CD pipeline"
```

This will run validation and plan (requires AWS credentials).

### Test 3: Deploy to Production
```bash
# Merge the PR
gh pr merge --merge

# Or push directly to main
git checkout main
git pull
# Make changes
git push
```

This will trigger the full deployment.

## Troubleshooting

### Error: "Credentials could not be loaded"
- Verify secrets are set: `gh secret list`
- Check secret names match exactly: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Ensure AWS credentials are valid: `aws sts get-caller-identity`

### Error: "UnauthorizedOperation"
- Check IAM user has required permissions
- Verify credentials are for the correct AWS account

### Error: "Backend initialization required"
- The workflow uses local backend by default
- For production, consider using S3 backend with state locking

## Best Practices

1. **Use Separate AWS Accounts**
   - Development: For testing
   - Production: For live infrastructure

2. **Use IAM Roles Instead of Access Keys**
   - Configure OIDC provider in AWS
   - Use `aws-actions/configure-aws-credentials` with role assumption

3. **Enable Branch Protection**
   - Require PR reviews before merging
   - Require status checks to pass

4. **Use Terraform Backend**
   - Store state in S3
   - Enable state locking with DynamoDB

## Advanced: Using OIDC (Recommended for Production)

Instead of storing AWS credentials, use OIDC:

1. Create an OIDC provider in AWS IAM
2. Create an IAM role with trust policy for GitHub
3. Update workflow to use role assumption:

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT_ID:role/GitHubActionsRole
    aws-region: us-east-1
```

4. Remove `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets

## Monitoring

View workflow runs:
```bash
gh run list
gh run view <run-id>
gh run watch
```

## Next Steps

1. Add AWS credentials as secrets
2. Test the validation workflow
3. Create a pull request to test planning
4. Merge to main to deploy infrastructure
5. Monitor the deployment in GitHub Actions
6. Access your application via the ALB DNS output

## Support

For issues with:
- GitHub Actions: Check the Actions tab in your repository
- AWS Credentials: Verify in AWS IAM console
- Terraform: Check the workflow logs for detailed errors
