# youtube_IaC

Terraform repository for AWS infrastructure of a simple YouTube clone.

## Infrastructure flow

User -> CloudFront -> S3 (frontend) -> ALB -> EC2 backend (Auto Scaling) -> DB + S3 (videos/thumbnails)

## Networking baseline

The repository defines a network topology with:

- One VPC
- Two public subnets (one per AZ)
- Two private backend subnets (one per AZ)
- Two private DB subnets (one per AZ)
- One Internet Gateway
- One NAT Gateway
- Route isolation between backend and DB tiers

Detailed network design, inputs, outputs, and routing rules are documented in `modules/networking/README.md`.

## Security baseline

The repository defines a security group model with:

- ALB SG with HTTPS `443` ingress from CloudFront origin-facing managed prefix list
- Backend SG with TCP `8000` ingress from ALB SG
- DB SG with TCP `5432` ingress from backend SG
- Restricted DB SG egress (to backend SG)

Detailed security design, inputs, outputs, and rules are documented in `modules/security/README.md`.

## Storage baseline

The repository defines a storage layer with:

- RDS PostgreSQL instance in private DB subnets
- Multi-AZ standby replication for data safety
- S3 bucket for videos with account-scoped naming (`<prefix>-<account_id>`)
- Public access block configuration on the S3 video bucket

Detailed storage design, inputs, outputs, and module contract are documented in `modules/storage/README.md`.

## Backend baseline

The repository defines a backend application layer with:

- Public ALB for API ingress
- Target Group and HTTP listener
- Launch Template with backend bootstrap script
- Auto Scaling Group in private backend subnets
- Backend app environment wiring (`FRONTEND_URL` and `DB_HOST`)

Detailed backend design, inputs, outputs, and module contract are documented in `modules/backend/README.md`.

## Active module integration

Root `main.tf` wires:

- `module.networking` for VPC and subnet tiers
- `module.security` for ALB/backend/DB SG controls
- `module.storage` using `module.networking.private_db_subnets` and `module.security.db_sg_id`
- `module.backend` using networking subnets, security SGs, and storage DB endpoint

## Terraform commands

Run from repository root:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```
