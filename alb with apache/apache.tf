# Create security group
resource "aws_security_group" "apache-sg" {
  name        = "apache-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Vpc_main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.249.77.103/32"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description     = "TLS from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "apache-sg"
  }
}

# Creation of ec2 
resource "aws_instance" "apache" {
  ami                    = "ami-0d593311db5abb72b"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.id
  subnet_id              = "subnet-01912426adc291536"
  vpc_security_group_ids = [aws_security_group.apache-sg.id]
  count                  = length(var.ec2_name)
  user_data              = <<EOF
             #!/bin/bash
             yum update -y
             yum install httpd -y 
             systemctl enable httpd
             systemctl start httpd
       EOF


  tags = {
    Name = element(var.ec2_name, count.index)

  }
}
