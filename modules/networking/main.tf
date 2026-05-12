resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "youtube-vpc" }
}

# Subredes Públicas (ALB / NAT)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-${count.index + 1}" }
}

# Subredes Privadas para Backend (App)
resource "aws_subnet" "private_back" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_back_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "private-back-subnet-${count.index + 1}" }
}

# Subredes Privadas para DB (RDS)
resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_db_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "private-db-subnet-${count.index + 1}" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "youtube-igw" }
}

# NAT Gateway (Solo uno en la primera subnet pública para ahorrar)
resource "aws_eip" "nat" { domain = "vpc" }

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "youtube-nat" }
}

# --- TABLA PÚBLICA (Hacia Internet Gateway) ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

# --- TABLA PRIVADA BACKEND (Hacia NAT Gateway) ---
resource "aws_route_table" "private_back" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = { Name = "private-back-rt" }
}

# --- TABLA PRIVADA DB ---
# La base de datos no necesita salida a Internet por NAT.
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "private-db-rt" }
}

# Asociar subredes públicas
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Asociar subredes privadas de Backend
resource "aws_route_table_association" "private_back" {
  count          = 2
  subnet_id      = aws_subnet.private_back[count.index].id
  route_table_id = aws_route_table.private_back.id
}

# Asociar subredes privadas de DB
resource "aws_route_table_association" "private_db" {
  count          = 2
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}

