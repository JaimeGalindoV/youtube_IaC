# Módulo de Red: Crea el esqueleto
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

# Módulo de Seguridad: Define quién habla con quién
module "security" {
  source = "./modules/security"
  
  vpc_id = module.networking.vpc_id
}

# Módulo de Cómputo: El Backend
module "compute" {
  source = "./modules/compute"

  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnets
  private_subnets    = module.networking.private_subnets
  backend_sg_id      = module.security.backend_sg_id
  alb_sg_id          = module.security.alb_sg_id
  instance_type      = "t3.micro"
}