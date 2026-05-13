# Para construir un nombre de bucket globalmente único.
data "aws_caller_identity" "current" {}

# 1. Grupo de Subnets para la Base de Datos
resource "aws_db_subnet_group" "main" {
  name       = "youtube-db-subnet-group"
  subnet_ids = var.private_db_subnets

  tags = { Name = "db-subnet-group" }
}

# 2. Base de Datos RDS (PostgreSQL/MySQL)
resource "aws_db_instance" "youtube_db" {
  allocated_storage      = 20
  db_name                = "youtubedb"
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot    = true
  multi_az               = true
}

# 3. S3 Bucket para Videos
resource "aws_s3_bucket" "video_storage" {
  bucket = "${var.video_bucket_prefix}-${data.aws_caller_identity.current.account_id}"
}

# Bloqueo de acceso público (Obligatorio por políticas de la cuenta)
resource "aws_s3_bucket_public_access_block" "video_storage_block" {
  bucket = aws_s3_bucket.video_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
