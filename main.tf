provider "aws" {
  region = "us-west-1" 
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1b"
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-1a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-1b"
}

resource "aws_instance" "web_instance_1" {
  ami           = "ami-0989fb15ce71ba39e" #ami de ubuntu server 22.04
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id

  user_data = <<-EOF
                #!/bin/bash
                apt update
                apt install -y apache2
                echo "Instance: ${aws_instance.web_instance_1.id}, Region: ${var.region}" > /var/www/html/index.html
                systemctl start apache2
                systemctl enable apache2
                EOF
}

resource "aws_instance" "web_instance_2" {
  ami           = "ami-0989fb15ce71ba39e" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y apache2
              echo "Instance: ${aws_instance.web_instance_2.id}, Region: ${var.region}" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_security_group" "lb_sg" {
  name_prefix = "lb-sg-"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    type             = "forward"
  }
}
