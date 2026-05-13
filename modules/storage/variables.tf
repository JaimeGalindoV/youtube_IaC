variable "private_db_subnets" {
  description = "IDs de subnets privadas para la base de datos RDS"
  type        = list(string)
}

variable "db_username" {
  description = "Username para la base de datos"
  type        = string
}

variable "db_password" {
  description = "Password para la base de datos"
  type        = string
  sensitive   = true
}

variable "db_sg_id" {
  description = "ID del Security Group para la base de datos RDS"
  type        = string
}

variable "db_engine_version" {
  description = "Version de PostgreSQL para RDS. Si es null, AWS selecciona una version compatible."
  type        = string
  default     = null
}

variable "video_bucket_prefix" {
  description = "Prefijo para el bucket S3 de videos. Se completa con el account ID para hacerlo unico."
  type        = string
  default     = "youtube-clone-videos"
}
