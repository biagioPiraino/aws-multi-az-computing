# AWS Multi-AZ Computing

Deploy auto scaled, distributed and multi-AZ computing power on AWS using Terraform :cloud:

The script includes the creation of the following resources:
- A VPC with public subnets that span across different Availability Zones in the eu-west-1 region
- An Application Load Balancer that operates in the VPC's public subnets
- An Auto Scaling Group with Amazon-Linux t2.micro instances running in the VPC
- Appropriate Security Groups to enforce a strict communication between the ALB and ASG's instances
