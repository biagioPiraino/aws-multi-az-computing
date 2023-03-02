# Create an ALB that will operate across the VPC public subnets
resource "aws_lb" "application-load-balancer" {
  name = "application-load-balancer"
  load_balancer_type = "application"
  security_groups = [ aws_security_group.allow-all-http-traffic.id ]
  subnets = module.vpc.public_subnets
  internal = false
}

# Create three EC2 Instances that will operate in the VPC private subnets
# To test the responsivness of the server, a dummy user data has been provisioned
resource "aws_instance" "ec2-instances" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  ami = "ami-065793e81b1869261" # Defined specific ami id from aws management console
  instance_type = "t2.micro"
  vpc_security_group_ids = [ 
    aws_security_group.allow-http-traffic-from-alb.id,
    aws_security_group.allow-ssh-traffic.id ]
  associate_public_ip_address = false
  subnet_id = module.vpc.private_subnets[count.index]
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

# Create a target group for the ALB
resource "aws_lb_target_group" "application-load-balancer-tg" {
  name = "application-load-balancer-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
}

# Register all the three instances to the target group 
resource "aws_lb_target_group_attachment" "alb-tg-attachment" {
  count = 3
  target_group_arn = aws_lb_target_group.application-load-balancer-tg.arn
  target_id = aws_instance.ec2-instances.*.id[count.index]
  port = 80
}

# Create an ALB listener to redirect the traffic from the ALB to the Target Group
resource "aws_lb_listener" "learn-tf-lb-listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port = 80
  protocol = "HTTP"
  
  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.application-load-balancer-tg.arn
  }
}

# Create a security group that allow all HTTP traffic (this will be attached to the ALB)
resource "aws_security_group" "allow-all-http-traffic" {
  name = "allow-all-http-traffic"
  vpc_id = module.vpc.vpc_id
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

# Create a security group that allow HTTP traffic from the ALB only 
# (this will be attached to the instances)
resource "aws_security_group" "allow-http-traffic-from-alb" {
  name = "allow-http-traffic-from-alb"
  vpc_id = module.vpc.vpc_id
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

# Create a security group that allow SSH traffic from port 22 
# (this will be attached to the instances)
resource "aws_security_group" "allow-ssh-traffic" {
  name = "allow-ssh-traffic-from-alb"
  vpc_id = module.vpc.vpc_id
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