variable "alb_sg_id" {
  description = "ID del Security Group del ALB"
  type        = string
}

variable "backend_sg_id" {
  description = "ID del Security Group del backend"
  type        = string
}

variable "public_subnets" {
  description = "Subredes publicas para el ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "Subredes privadas para instancias backend"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "frontend_url" {
  description = "URL del frontend autorizada por el backend"
  type        = string
}

variable "db_host" {
  description = "Host/endpoint de la base de datos"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "youtubedb"
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Password de la base de datos"
  type        = string
  sensitive   = true
}

variable "storage_bucket_arn" {
  description = "ARN del bucket S3 de storage para videos"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 del backend"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Puerto donde corre la app backend"
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "Ruta para health check del target group"
  type        = string
  default     = "/api/health"
}

variable "backend_repo_url" {
  description = "Repositorio del backend para bootstrap en EC2"
  type        = string
  default     = "https://github.com/JaimeGalindoV/youtube_back.git"
}

variable "min_size" {
  description = "Capacidad minima del ASG"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Capacidad deseada del ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Capacidad maxima del ASG"
  type        = number
  default     = 4
}
