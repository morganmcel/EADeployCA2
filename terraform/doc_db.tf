resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "ea-design-bps"
  engine                  = "docdb"
  master_username         = var.DB_USERNAME
  master_password         = var.DB_PASSWORD
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}