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

## Terraform commands

Run from repository root:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```
