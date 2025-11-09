output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.asg_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}
