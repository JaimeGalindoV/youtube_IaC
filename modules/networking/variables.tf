variable "vpc_cidr" {
  description = "CIDR principal de la VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs para las subredes públicas"
  type        = list(string)
}

variable "private_back_cidrs" {
  description = "CIDRs para las subredes privadas de backend"
  type        = list(string)
}

variable "private_db_cidrs" {
  description = "CIDRs para las subredes privadas de base de datos"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zonas de disponibilidad a usar"
  type        = list(string)
}
