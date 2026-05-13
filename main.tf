# Módulo de Red: Crea el esqueleto
module "networking" {
  source = "./modules/networking"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_back_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"] # Para EC2
  private_db_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"] # Para RDS
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

# Módulo de Seguridad: Define quién habla con quién
module "security" {
  source = "./modules/security"

  vpc_id = module.networking.vpc_id
}

module "storage" {
  source = "./modules/storage"

  private_db_subnets  = module.networking.private_db_subnets
  db_sg_id            = module.security.db_sg_id
  db_username         = var.db_username
  db_password         = var.db_password
  db_engine_version   = var.db_engine_version
  video_bucket_prefix = var.video_bucket_prefix
}
