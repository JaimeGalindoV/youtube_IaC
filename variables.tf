variable "db_username" {
  description = "Username para la base de datos"
  type        = string
}

variable "db_password" {
  description = "Password para la base de datos"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "Version de PostgreSQL para RDS. Si es null, AWS selecciona una version compatible."
  type        = string
  default     = null
}

variable "video_bucket_prefix" {
  description = "Prefijo para el bucket S3 de videos."
  type        = string
  default     = "ourtube-videos"
}

variable "frontend_url" {
  description = "URL del frontend para CORS/backend"
  type        = string
  default     = "http://localhost:3000"
}
