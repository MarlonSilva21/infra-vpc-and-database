#provisionamento vpc
resource "aws_vpc" "cluster-vpc-bb" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VpcBluesBurger"
  }
}

# provisionamento subnets publicas
resource "aws_subnet" "cluster-vpc-subnet-public-1" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "SubnetPublicBluesBurger1"
  }
}

resource "aws_subnet" "cluster-vpc-subnet-public-2" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "SubnetPublicBluesBurger2"
  }
}

# provisionamento subnets privadas
resource "aws_subnet" "cluster-vpc-subnet-private-1" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "SubnetPrivateBluesBurger1"
  }
}

resource "aws_subnet" "cluster-vpc-subnet-private-2" {
  vpc_id            = aws_vpc.cluster-vpc-bb.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "SubnetPrivateBluesBurger2"
  }
}

# provisionamento internet gateway
resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-vpc-bb.id

  tags = {
    Name = "InternetGatewayBluesBurger"
  }
}

# provisionamento NAT gateway
resource "aws_eip" "cluster-eip-nat-gateway" {
  domain = vpc
}

resource "aws_nat_gateway" "cluster-nat-gateway" {
  allocation_id = aws_eip.cluster-eip-nat-gateway.id
  subnet_id     = aws_subnet.cluster-vpc-subnet-public-1.id
}


# provisionamento route table
resource "aws_route_table" "cluster-route-table" {
  vpc_id = aws_vpc.cluster-vpc-bb.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster-igw.id
  }

  tags = {
    Name = "RouteTableBluesBurger"
  }
}

# provisionamento de uma rota para o NAT Gateway para as subnets privadas
resource "aws_route" "private_subnet_1_nat_route" {
  route_table_id         = aws_route_table.cluster-route-table.id
  nat_gateway_id         = aws_nat_gateway.cluster-nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_route" "private_subnet_2_nat_route" {
  route_table_id = aws_route_table.cluster-route-table.id
  nat_gateway_id = aws_nat_gateway.cluster-nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

# provisionamento route table association
resource "aws_route_table_association" "cluster-rta-public-1" {
  route_table_id = aws_route_table.cluster-route-table.id
  subnet_id      = aws_subnet.cluster-vpc-subnet-public-1.id
}

resource "aws_route_table_association" "cluster-rta-public-2" {
  route_table_id = aws_route_table.cluster-route-table.id
  subnet_id      = aws_subnet.cluster-vpc-subnet-public-2.id
}


