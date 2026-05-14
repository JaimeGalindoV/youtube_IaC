variable "alb_dns_name" {
  description = "DNS del ALB backend para enrutar /api/* desde CloudFront"
  type        = string
}

variable "frontend_bucket_prefix" {
  description = "Prefijo para bucket del frontend (se completa con account_id)"
  type        = string
  default     = "youtube-frontend"
}
