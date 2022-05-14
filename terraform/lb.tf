resource "aws_lb" "app_alb" {
  name               = var.aws_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.public.ids
  security_groups    = ["${aws_security_group.allow_http.id}"]

  depends_on = [aws_security_group.allow_http]
}
resource "aws_lb_target_group" "fe-tg" {
  name        = var.aws_alb_fe_tg_name
  port        = var.aws_alb_fe_tg_port
  protocol    = var.aws_alb_fe_tg_protocol
  vpc_id      = aws_vpc.eadeploy-vpc.id
  target_type = "ip"

  depends_on = [aws_lb.app_alb]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe-tg.arn
  }
}

## Backend

resource "aws_lb_target_group" "be-tg" {
  name        = var.aws_alb_be_tg_name
  port        = var.aws_alb_be_tg_port
  protocol    = var.aws_alb_be_tg_protocol
  vpc_id      = aws_vpc.eadeploy-vpc.id
  target_type = "ip"

  depends_on = [aws_lb.app_alb]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "back_end_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "8080"
  protocol          = "HTTP"
  #  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be-tg.arn
  }
}




data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "dns" {
  zone_id = var.hosted_zone
  name    = format("%s.%s", var.dns_name, var.domain_suffix)
  type    = "A"

  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = false
  }
  depends_on = [aws_lb.app_alb]
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.eadeploy-vpc.id

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Anywhere"
    from_port   = 443
    to_port     = 443
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
    Name = "allow_web"
  }
}

resource "aws_security_group" "container_access" {
  name        = "container_access"
  description = "Allow LB to reach container"
  vpc_id      = aws_vpc.eadeploy-vpc.id

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "Backend Access"
    from_port   = 22137
    to_port     = 22137
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 2000
    to_port     = 2000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
