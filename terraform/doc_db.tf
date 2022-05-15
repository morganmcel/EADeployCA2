resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "ea-design-bps"
  engine                  = "docdb"
  master_username         = data.aws_ssm_parameter.docdb-user.value
  master_password         = data.aws_ssm_parameter.docdb-password.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.docdb_access.id]
  db_subnet_group_name    = aws_db_subnet_group.docdb_subnet_group.id
}

resource "aws_docdb_cluster_instance" "ea-deploy-docdb" {
  count                      = 1
  cluster_identifier         = aws_docdb_cluster.docdb.cluster_identifier
  apply_immediately          = true
  instance_class             = var.doc_db_instance_class
  auto_minor_version_upgrade = true

}

data "aws_ssm_parameter" "docdb-user" {
  name = "/eadesign/db_username"
}

data "aws_ssm_parameter" "docdb-password" {
  name = "/eadesign/db_password"
}

resource "aws_db_subnet_group" "docdb_subnet_group" {
  name       = "documentdb_subnet_group"
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    Name = "DocumentDB subnet group"
  }
}


resource "aws_security_group" "docdb_access" {
  name        = "docdb access"
  description = "Allow other containers to reach docdb"
  vpc_id      = aws_vpc.eadeploy-vpc.id

  ingress {
    description = "DocDB from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_docdb"
  }
}

