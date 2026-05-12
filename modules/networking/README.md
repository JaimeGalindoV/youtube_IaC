# Networking module

`modules/networking` defines the foundational VPC topology for multi-tier workloads.

## Resources created

- `aws_vpc.this`
- `aws_subnet.public[2]`
- `aws_subnet.private_back[2]`
- `aws_subnet.private_db[2]`
- `aws_internet_gateway.igw`
- `aws_eip.nat`
- `aws_nat_gateway.this`
- `aws_route_table.public`
- `aws_route_table.private_back`
- `aws_route_table.private_db`
- Route table associations for all subnet tiers

## Routing model

- **Public subnets**: `0.0.0.0/0 -> Internet Gateway`
- **Backend private subnets**: `0.0.0.0/0 -> NAT Gateway`
- **DB private subnets**: no default internet route

This keeps application compute with controlled egress and leaves DB subnets isolated from direct internet egress.

## Input variables

| Name | Type | Description |
| --- | --- | --- |
| `vpc_cidr` | `string` | CIDR principal de la VPC |
| `public_subnet_cidrs` | `list(string)` | CIDRs para las subredes públicas |
| `private_back_cidrs` | `list(string)` | CIDRs para las subredes privadas de backend |
| `private_db_cidrs` | `list(string)` | CIDRs para las subredes privadas de base de datos |
| `availability_zones` | `list(string)` | Zonas de disponibilidad a usar |

## Outputs (integration contract)

| Output | Description |
| --- | --- |
| `vpc_id` | ID de la VPC creada |
| `public_subnets` | IDs de subredes publicas |
| `private_subnets` | IDs de subredes privadas de backend |
| `private_back_subnets` | IDs de subredes privadas para backend |
| `private_db_subnets` | IDs de subredes privadas para base de datos |

## Usage from root module

```hcl
module "networking" {
  source = "./modules/networking"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_back_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  private_db_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
}
```
