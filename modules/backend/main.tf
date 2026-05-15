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

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backend_ec2_role" {
  name               = "youtube-backend-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "backend_s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${var.storage_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "backend_s3_policy" {
  name   = "youtube-backend-s3-access"
  role   = aws_iam_role.backend_ec2_role.id
  policy = data.aws_iam_policy_document.backend_s3_access.json
}

resource "aws_iam_instance_profile" "backend_profile" {
  name = "youtube-backend-ec2-profile"
  role = aws_iam_role.backend_ec2_role.name
}

resource "aws_launch_template" "backend_lt" {
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.backend_profile.name
  }

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
    echo "Completed! Starting backend setup..."
    pip3 install -r requirements.txt
    echo "Requirements installed. Setting environment variables..."
    cat > .env <<ENVVARS
    FRONTEND_URL=${var.frontend_url}
    DB_HOST=${var.db_host}
    DB_PORT=5432
    DB_NAME=${var.db_name}
    DB_USER=${var.db_user}
    DB_PASSWORD=${var.db_password}
    AWS_REGION=us-east-1
    UPLOAD_DIR=uploads
    ENVVARS
    echo "Environment variables set. Starting the backend server..."

    # Lanzar uvicorn capturando errores en un archivo que podamos ver
    nohup uvicorn main:app --host 0.0.0.0 --port ${var.app_port} > /home/ec2-user/app.log 2>&1 &

    # Darle unos segundos y mostrar el log en el system output para que lo veas en la consola de AWS
    sleep 5
    cat /home/ec2-user/app.log

    echo "Backend server started successfully!"
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