# AWS Multi-AZ Computing

Deploy secure, distributed and multi-AZ computing power on AWS using Terraform :cloud:

The script includes the creation of the following resources:
- A VPC with public subnets that span across different Availability Zones in the eu-west-1 region
- An Application Load Balancer that operates in the VPC's public subnets
- A fleet of two EC2 instances that operates in the VPC's private subnets
- NAT Gateways deployed in the public subnets to allow EC2 instances to communicate with the 'outside world'
- Appropriate Security Groups to enforce a strict communication between the ALB and the EC2 instances
