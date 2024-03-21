# Provisionamento da subnet do RDS
resource "aws_db_subnet_group" "subnet-rds" {
  name       = var.project_name
  subnet_ids = [aws_subnet.cluster-vpc-subnet-private-1.id, aws_subnet.cluster-vpc-subnet-private-2.id]
}

# Provisionamento de uma instância RDS
resource "aws_db_instance" "rds" {
  db_name                      = var.project_name
  engine                       = var.engine_rds
  engine_version               = var.engine_rds_version
  identifier                   = "rds-${var.project_name}"
  username                     = var.rds_user
  password                     = var.rds_pass
  instance_class               = var.instance_class
  storage_type                 = var.storage_type
  allocated_storage            = var.min_storage
  max_allocated_storage        = var.max_storage
  vpc_security_group_ids       = [aws_security_group.sg-rds.id]
  db_subnet_group_name         = aws_db_subnet_group.subnet-rds.id
  multi_az                     = false
  apply_immediately            = true
  skip_final_snapshot          = true
  publicly_accessible          = false
  deletion_protection          = false
  performance_insights_enabled = false
  backup_retention_period      = 1
  copy_tags_to_snapshot        = true
  delete_automated_backups     = true

  backup_window = var.backup_window

  tags = {
    Name = "db-${var.project_name}"
  }
}
