output "db_instance_id" {
  description = "ID de la instancia RDS"
  value       = aws_db_instance.youtube_db.id
}

output "db_endpoint" {
  description = "Endpoint de conexion de la base de datos"
  value       = aws_db_instance.youtube_db.endpoint
}

output "video_bucket_name" {
  description = "Nombre del bucket S3 para videos"
  value       = aws_s3_bucket.video_storage.bucket
}

output "video_bucket_arn" {
  description = "ARN del bucket S3 para videos"
  value       = aws_s3_bucket.video_storage.arn
}
