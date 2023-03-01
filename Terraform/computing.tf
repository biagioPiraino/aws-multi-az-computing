resource "aws_lb" "application-load-balancer" {
  name = "application-load-balancer"
  load_balancer_type = "application"
  security_groups = [ aws_security_group.allow-all-http-traffic.id ]
  subnets = ["subnet-01626029388b5b8bf", "subnet-0a30c3846db1024d8", "subnet-0f95335da54aaaa90"]
  internal = false
}

resource "aws_instance" "ec2-instances" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  ami = "ami-065793e81b1869261" # Defined specific ami id from aws management console
  instance_type = "t2.micro"
  security_groups = [ 
    aws_security_group.allow-http-traffic-from-alb.name,
    aws_security_group.allow-ssh-traffic.name ]
  vpc_security_group_ids = [ 
    aws_security_group.allow-http-traffic-from-alb.id,
    aws_security_group.allow-ssh-traffic.id ]
  associate_public_ip_address = true
  user_data = <<EOF
  #!/bin/bash
  # Use this for your user data (script from top to bottom)
  # install httpd (Linux 2 version)
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
}

resource "aws_lb_target_group" "application-load-balancer-tg" {
  name = "application-load-balancer-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-0c9fbc589930e89e4"
}

resource "aws_lb_target_group_attachment" "alb-tg-attachment" {
  count = 3
  target_group_arn = aws_lb_target_group.application-load-balancer-tg.arn
  target_id = aws_instance.ec2-instances.*.id[count.index]
  port = 80
}

resource "aws_lb_listener" "learn-tf-lb-listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port = 80
  protocol = "HTTP"
  
  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.application-load-balancer-tg.arn
  }
}

resource "aws_security_group" "allow-all-http-traffic" {
  name = "allow-all-http-traffic"
  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all HTTP traffic at port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}

resource "aws_security_group" "allow-http-traffic-from-alb" {
  name = "allow-http-traffic-from-alb"
  ingress = [ {
    cidr_blocks = []
    description = "Allow HTTP traffic from ALB"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = [aws_security_group.allow-all-http-traffic.id]
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}

resource "aws_security_group" "allow-ssh-traffic" {
  name = "allow-ssh-traffic-from-alb"
  ingress = [ {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic at port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  } ]
}


#############################################################################
# So let's try to break up this process
# You do have 2 main components which are an ALB and an ASG

# These entities will opearate on a multi AZ level inside a vpc
# So the first step is to create a VPC using terraform module

# A module is a container for multiple resources that are used together. 
# You can use modules to create lightweight abstractions, so that you can 
# describe your infrastructure in terms of its architecture, rather than 
# directly in terms of physical objects.
# module "vpc" {
#     source  = "terraform-aws-modules/vpc/aws"
#     version = "2.77.0"

#     name = "main-vpc"
#     cidr = "10.0.0.0/16"

#     azs = data.aws_availability_zones.available.names
#     public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
# }

# # Second step is to define an ALB that operates in the VPC public subnets...
# resource "aws_lb" "learn-tf-alb" {
#   name = "learn-tf-alb"
#   internal = false
#   load_balancer_type = "application"
#   subnets = module.vpc.public_subnets
#   security_groups = [aws_security_group.learn-tf-alb-sg.id]
# }

# # ...that allows TCP traffic from everywhere
# resource "aws_security_group" "learn-tf-alb-sg" {
#     name = "learn-tf-alb-sg"
#     ingress = [ {
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "allow tcp traffic from anywhere"
#       from_port = 80
#       ipv6_cidr_blocks = []
#       prefix_list_ids = []
#       protocol = "tcp"
#       security_groups = []
#       self = false
#       to_port = 80
#     } ]

#     egress = [ {
#       cidr_blocks = [ "0.0.0.0/0" ]
#       description = "allow all outbound traffic"
#       from_port = 0
#       ipv6_cidr_blocks = []
#       prefix_list_ids = []
#       protocol = "-1" # All protocols
#       security_groups = []
#       self = false
#       to_port = 0
#     } ]

#     vpc_id = module.vpc.vpc_id
# }

# # The third step is to create the infrastructure for the ASG
# # First thing first we should create a launch configuration for the instances
# # that will be created/destroyed in the autoscaling process...
# data "aws_ami" "amazon-linux" {
#     most_recent = true
#     owners = ["amazon"]
#     # Filter values picked from Terraform documentation
#     filter {
#       name = "name"
#       values = ["amzn-ami-hvm-*-x86_64-ebs"] 
#     }
# }

# resource "aws_launch_configuration" "learn-tf-launch_configuration" {
#     name_prefix = "learn-tf-launch_configuration-"
#     image_id = data.aws_ami.amazon-linux.id
#     instance_type = "t2.micro"
#     security_groups = [aws_security_group.learn-tf-instance-sg.id]

#     lifecycle {
#         # Necessary if changing 'name' or 'name_prefix' properties.
#         create_before_destroy = true
#     } 
# }

# # ... that accept traffic only from the ALB using TCP protocol
# resource "aws_security_group" "learn-tf-instance-sg" {
#     name = "learn-tf-instance-sg"
#     ingress = [ {
#         cidr_blocks = []
#         description = "allow tcp traffic from the ALB only"
#         from_port = 80
#         ipv6_cidr_blocks = []
#         prefix_list_ids = []
#         protocol = "tcp"
#         security_groups = [aws_security_group.learn-tf-alb-sg.id]
#         self = false
#         to_port = 80
#     } ] 
    
#     egress = [ {
#         cidr_blocks = []
#         description = "allow all outbound traffic to the ALB"
#         from_port = 0
#         ipv6_cidr_blocks = []
#         prefix_list_ids = []
#         protocol = "-1" # All protocols
#         security_groups = [aws_security_group.learn-tf-alb-sg.id]
#         self = false
#         to_port = 0
#     } ]

#     vpc_id = module.vpc.vpc_id
# }

# # Afterwards we can create the ASG using the resource previously created
# resource "aws_autoscaling_group" "learn-tf-asg" {
#     name = "learn-tf-asg"
#     min_size = 1
#     desired_capacity = 1
#     max_size = 3
#     launch_configuration = aws_launch_configuration.learn-tf-launch_configuration.name
#     vpc_zone_identifier = module.vpc.public_subnets

#     tag {
#         key                 = "name"         # Required
#         value               = "learn-tf-asg" # Required
#         # Enables propagation of the tag to Amazon EC2 instances launched via this ASG
#         propagate_at_launch = true 
#     }
# }

# # Fourth and last step is to connect these two pieces together
# # To connect them successfully we need to deploy:
# #   1) a target group
# #   2) a listener to forward traffic from the alb to the target group
# #   3) a autoscaling group attachment to connect the target group to the autoscaling resource

# # 1)
# resource "aws_lb_target_group" "learn-tf-alb-tg" {
#     name = "learn-tf-alb-tg"
#     port = 80
#     protocol = "HTTP"
#     vpc_id = module.vpc.vpc_id
# }

# # 2)
# resource "aws_lb_listener" "learn-tf-lb-listener" {
#     load_balancer_arn = aws_lb.learn-tf-alb.arn
#     port = 80
#     protocol = "HTTP"
    
#     default_action {
#       	type = "forward"
#         target_group_arn = aws_lb_target_group.learn-tf-alb-tg.arn
#     }
# }

# # 3)
# resource "aws_autoscaling_attachment" "laern-tf-as-att" {
#     autoscaling_group_name = aws_autoscaling_group.learn-tf-asg.id
#     lb_target_group_arn = aws_lb_target_group.learn-tf-alb-tg.arn
# }