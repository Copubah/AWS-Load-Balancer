locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_security_group = module.security.alb_security_group_id
}

module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  instance_type      = var.instance_type
  public_subnet_ids  = module.vpc.public_subnet_ids
  ec2_security_group = module.security.ec2_security_group_id
  target_group_arn   = module.alb.target_group_arn
  min_size           = var.min_size
  max_size           = var.max_size
  desired_size       = var.desired_size
  user_data_script   = file("${path.module}/user_data.sh")
}
