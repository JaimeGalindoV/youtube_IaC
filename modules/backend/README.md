# Backend module

`modules/backend` deploys the application traffic layer for the backend API.

## Resources created

- `aws_lb.backend_alb`
- `aws_lb_target_group.backend_tg`
- `aws_lb_listener.http`
- `aws_launch_template.backend_lt`
- `aws_autoscaling_group.backend_asg`

## Runtime model

- Public ALB in public subnets receives HTTP traffic.
- Target Group forwards traffic to backend instances on `app_port` (default `8000`).
- EC2 instances run in private backend subnets through an Auto Scaling Group.
- User data bootstraps the backend app, writes `.env`, and starts Uvicorn.

## Input variables

| Name | Type | Description |
| --- | --- | --- |
| `alb_sg_id` | `string` | ID del Security Group del ALB |
| `backend_sg_id` | `string` | ID del Security Group del backend |
| `public_subnets` | `list(string)` | Subredes publicas para el ALB |
| `private_subnets` | `list(string)` | Subredes privadas para instancias backend |
| `vpc_id` | `string` | ID de la VPC |
| `frontend_url` | `string` | URL del frontend autorizada por el backend |
| `db_host` | `string` | Host/endpoint de la base de datos |
| `instance_type` | `string` | Tipo de instancia EC2 del backend |
| `app_port` | `number` | Puerto donde corre la app backend |
| `health_check_path` | `string` | Ruta para health check del target group |
| `backend_repo_url` | `string` | Repositorio del backend para bootstrap en EC2 |
| `min_size` | `number` | Capacidad minima del ASG |
| `desired_capacity` | `number` | Capacidad deseada del ASG |
| `max_size` | `number` | Capacidad maxima del ASG |

## Outputs (integration contract)

| Output | Description |
| --- | --- |
| `alb_dns_name` | DNS publico del ALB backend |
| `alb_arn` | ARN del ALB backend |
| `target_group_arn` | ARN del target group del backend |
| `asg_name` | Nombre del Auto Scaling Group del backend |

## Usage from root module

```hcl
module "backend" {
  source = "./modules/backend"

  alb_sg_id        = module.security.alb_sg_id
  public_subnets   = module.networking.public_subnets
  vpc_id           = module.networking.vpc_id
  backend_sg_id    = module.security.backend_sg_id
  frontend_url     = var.frontend_url
  db_host          = module.storage.db_endpoint
  private_subnets  = module.networking.private_back_subnets
}
```
