data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# 1. Security Group para el ALB
resource "aws_security_group" "alb_sg" {
  name        = "youtube-alb-sg"
  description = "Permitir trafico HTTPS entrante solo desde CloudFront"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS solo desde CloudFront"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}

# 2. Security Group para el Backend
resource "aws_security_group" "backend_sg" {
  name        = "youtube-backend-sg"
  description = "Solo permite trafico desde el ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "FastAPI desde el ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "backend-sg" }
}

# 3. Security Group para el RDS (Capa de Datos)
resource "aws_security_group" "db_sg" {
  name        = "youtube-db-sg"
  description = "Solo permite trafico desde las instancias de backend"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Base de datos desde el Backend"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    description     = "Salida solo hacia backend"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.backend_sg.id]
  }

  tags = { Name = "db-sg" }
}
