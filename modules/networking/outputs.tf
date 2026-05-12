output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "IDs de subredes publicas"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs de subredes privadas de backend"
  value       = aws_subnet.private_back[*].id
}

output "private_back_subnets" {
  description = "IDs de subredes privadas para backend"
  value       = aws_subnet.private_back[*].id
}

output "private_db_subnets" {
  description = "IDs de subredes privadas para base de datos"
  value       = aws_subnet.private_db[*].id
}
