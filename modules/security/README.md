# Security module

`modules/security` defines the security group layer for ALB, backend, and database communication.

## Resources created

- `data.aws_ec2_managed_prefix_list.cloudfront_origin_facing`
- `aws_security_group.alb_sg`
- `aws_security_group.backend_sg`
- `aws_security_group.db_sg`

## Traffic model

- **CloudFront -> ALB**: HTTPS `443` allowed to ALB from AWS managed prefix list `com.amazonaws.global.cloudfront.origin-facing`.
- **ALB -> Backend**: TCP `8000` allowed to backend SG from ALB SG.
- **Backend -> DB**: TCP `5432` allowed to DB SG from backend SG.

## Egress model

- **ALB SG**: outbound allowed to `0.0.0.0/0`.
- **Backend SG**: outbound allowed to `0.0.0.0/0`.
- **DB SG**: outbound restricted to backend SG.

## Input variables

| Name | Type | Description |
| --- | --- | --- |
| `vpc_id` | `string` | ID de la VPC donde se crearán los Security Groups |

## Outputs (integration contract)

| Output | Description |
| --- | --- |
| `alb_sg_id` | Security Group ID del ALB |
| `backend_sg_id` | Security Group ID del backend |
| `db_sg_id` | Security Group ID de la base de datos |

## Usage from root module

```hcl
module "security" {
  source = "./modules/security"

  vpc_id = module.networking.vpc_id
}
```
