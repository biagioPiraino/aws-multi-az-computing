# Create an internal VPC that span across different AZs with public and private subnets
# To allow communication between the private instances and the public internet
# NAT gateways are deployed in each AZs
module "vpc" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"
  name = "internal-vpc"
  cidr = "10.0.0.0/16"
  azs = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_hostnames = true
  enable_nat_gateway = true
}