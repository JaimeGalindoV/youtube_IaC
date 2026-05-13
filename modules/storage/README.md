# Storage module

`modules/storage` provisions the data and object storage layer.

## Resources created

- `aws_db_subnet_group.main`
- `aws_db_instance.youtube_db`
- `aws_s3_bucket.video_storage`
- `aws_s3_bucket_public_access_block.video_storage_block`

## Data model

- **RDS PostgreSQL** in private DB subnets with `multi_az = true` for standby redundancy.
- **Single writer endpoint** exposed by RDS (`db_endpoint` output).
- **S3 video bucket** with account-scoped name:
  - `${video_bucket_prefix}-${account_id}`
- **Public access blocked** on the video bucket.

## Input variables

| Name | Type | Description |
| --- | --- | --- |
| `private_db_subnets` | `list(string)` | IDs de subnets privadas para la base de datos RDS |
| `db_username` | `string` | Username para la base de datos |
| `db_password` | `string` | Password para la base de datos (sensitive) |
| `db_sg_id` | `string` | ID del Security Group para la base de datos RDS |
| `db_engine_version` | `string` | Versión de PostgreSQL (null = AWS elige versión compatible) |
| `video_bucket_prefix` | `string` | Prefijo para el bucket de videos |

## Outputs (integration contract)

| Output | Description |
| --- | --- |
| `db_instance_id` | ID de la instancia RDS |
| `db_endpoint` | Endpoint de conexión de la base de datos |
| `video_bucket_name` | Nombre del bucket S3 para videos |
| `video_bucket_arn` | ARN del bucket S3 para videos |

## Usage from root module

```hcl
module "storage" {
  source = "./modules/storage"

  private_db_subnets  = module.networking.private_db_subnets
  db_sg_id            = module.security.db_sg_id
  db_username         = var.db_username
  db_password         = var.db_password
  db_engine_version   = var.db_engine_version
  video_bucket_prefix = var.video_bucket_prefix
}
```
