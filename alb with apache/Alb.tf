
resource "aws_security_group" "alb-sg" {
  name        = "alb"
  description = "Allow http inbound traffic"
  vpc_id      = "vpc-0abad90fadf8675c0"

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "albsg"
  }
}

resource "aws_lb" "test-alb" {
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = ["subnet-05f5b47a04788aacb", "subnet-0be0ab6b817c57ea9", "subnet-07d6e64ae0bc5c7a1"]



  tags = {
    Environment = "alb-sg"
  }
}

resource "aws_lb_target_group" "test-tg-apache-1" {
  name     = "test-tg-apache-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0abad90fadf8675c0"
}

resource "aws_lb_target_group_attachment" "test-tg-attachment-apache-1" {
  target_group_arn = aws_lb_target_group.test-tg-apache-1.arn
  target_id        = aws_instance.apache[0].id
  port             = 80
}


resource "aws_lb_target_group" "test-tg-apache-2" {
  name     = "test-tg-apache-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0abad90fadf8675c0"
}

resource "aws_lb_target_group_attachment" "test-tg-attachment-apache-2" {
  target_group_arn = aws_lb_target_group.test-tg-apache-2.arn
  target_id        = aws_instance.apache[1].id
  port             = 80
}


resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.test-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg-apache-1.arn
  }
}

resource "aws_lb_listener_rule" "test-apache-1-hostbased" {
  listener_arn = aws_lb_listener.alb-listener.arn
  #   priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg-apache-1.arn
  }

  condition {
    host_header {
      values = ["apache-1.sainath.quest"]
    }
  }
}

resource "aws_lb_listener_rule" "test-apache-2-hostbased" {
  listener_arn = aws_lb_listener.alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg-apache-2.arn
  }

  condition {
    host_header {
      values = ["apache-2.sainath.quest"]
    }
  }
}