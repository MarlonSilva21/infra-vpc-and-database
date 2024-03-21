# Provisionamento de Grupos de Segurança para Subnets Públicas
resource "aws_security_group" "public_subnet_sg" {
  vpc_id = aws_vpc.cluster-vpc-bb.id
  name   = "balancers-security-group"

  # Permitir tráfego HTTP inbound
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego de saída para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "balancers-security-group"
  }
}

# Provisionamento de Grupos de Segurança para Cluster ECS
resource "aws_security_group" "private_subnet_sg" {
  vpc_id = aws_vpc.cluster-vpc-bb.id
  name   = "cluster-security-group"

  # Permitir tráfego de entrada vindo do Security Group das Subnets Públicas
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_subnet_sg.id]
  }

  # Permitir tráfego de saída para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster-security-group"
  }
}

# Provisionamento de Grupos de Segurança para RDS
resource "aws_security_group" "sg-rds" {
  name   = "rds-blues-burger-security-group"
  vpc_id = aws_vpc.cluster-vpc-bb.id

  # Permitir tráfego de entrada vindo do Security Group do Cluster ECS
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_subnet_sg.id]
  }

  # Permitir tráfego de saída para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-blues-burger-security-group"
  }
}
