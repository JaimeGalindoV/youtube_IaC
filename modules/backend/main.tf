resource "aws_lb" "backend_alb" {
  name               = "youtube-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = { Name = "youtube-alb" }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "youtube-backend-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_launch_template" "backend_lt" {
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.backend_sg_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y git python3-pip

    cd /home/ec2-user
    if [ ! -d backend ]; then
      git clone ${var.backend_repo_url} backend
    fi
    cd backend
    pip3 install -r requirements.txt

    cat > .env <<ENVVARS
    FRONTEND_URL=${var.frontend_url}
    DB_HOST=${var.db_host}
    UPLOAD_DIR=uploads
    DB_PATH=videos.db
    ENVVARS

    nohup python3 -m uvicorn main:app --host 0.0.0.0 --port ${var.app_port} > /var/log/backend.log 2>&1 &
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "youtube-backend-instance"
    }
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                = "youtube-backend-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [aws_lb_target_group.backend_tg.arn]
  vpc_zone_identifier = var.private_subnets
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }
}