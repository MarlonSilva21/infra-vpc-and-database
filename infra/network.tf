# Provisionamento VPC
resource "aws_vpc" "cluster-vpc-bb" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-blues-burger"
  }
}

# Provisionamento Subnets Públicas
resource "aws_subnet" "cluster-vpc-subnet-public-1" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-blues-burger-1"
  }
}

resource "aws_subnet" "cluster-vpc-subnet-public-2" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-blues-burger-2"
  }
}

# Provisionamento Subnets Privadas
resource "aws_subnet" "cluster-vpc-subnet-private-1" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-private-blues-burger-1"
  }
}

resource "aws_subnet" "cluster-vpc-subnet-private-2" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-private-blues-burger-2"
  }
}

# Provisionamento Internet Gateway
resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-vpc-bb.id

  tags = {
    Name = "internet-gateway-blues-burger"
  }
}

# Provisionamento NAT Gateway
resource "aws_eip" "cluster-eip-nat-gateway" {
  domain = "vpc"
}

resource "aws_nat_gateway" "cluster-nat-gateway" {
  allocation_id = aws_eip.cluster-eip-nat-gateway.id
  subnet_id     = aws_subnet.cluster-vpc-subnet-public-1.id
}

# Provisionamento Tabela de Roteamento para Subnets Públicas
resource "aws_route_table" "cluster-route-table" {
  vpc_id = aws_vpc.cluster-vpc-bb.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster-igw.id
  }

  tags = {
    Name = "route-table-public"
  }
}

# Provisionamento Tabela de Roteamento para Subnets Privadas
resource "aws_route_table" "private_route_1" {
  vpc_id = aws_vpc.cluster-vpc-bb.id

  tags = {
    Name = "route-table-private-1"
  }
}

resource "aws_route_table" "private_route_2" {
  vpc_id = aws_vpc.cluster-vpc-bb.id

  tags = {
    Name = "route-table-private-2"
  }
}

# Provisionamento de uma rota para o NAT Gateway para as Subnets Privadas
resource "aws_route" "private_subnet_1_nat_route" {
  route_table_id         = aws_route_table.private_route_1.id
  nat_gateway_id         = aws_nat_gateway.cluster-nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_subnet_2_nat_route" {
  route_table_id         = aws_route_table.private_route_2.id
  nat_gateway_id         = aws_nat_gateway.cluster-nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

# Provisionamento Associação de Tabela de Roteamento para Subnets Públicas
resource "aws_route_table_association" "cluster-rta-public-1" {
  route_table_id = aws_route_table.cluster-route-table.id
  subnet_id      = aws_subnet.cluster-vpc-subnet-public-1.id
}

resource "aws_route_table_association" "cluster-rta-public-2" {
  route_table_id = aws_route_table.cluster-route-table.id
  subnet_id      = aws_subnet.cluster-vpc-subnet-public-2.id
}

# Provisionamento Associação de Tabela de Roteamento para Subnets Privadas
resource "aws_route_table_association" "cluster-rta-private-1" {
  route_table_id = aws_route_table.private_route_1.id
  subnet_id      = aws_subnet.cluster-vpc-subnet-private-1.id
}

resource "aws_route_table_association" "cluster-rta-private-2" {
  route_table_id = aws_route_table.private_route_2.id
  subnet_id      = aws_subnet.cluster-vpc-subnet-private-2.id
}
