variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["eu-west-1a", "eu-west-1c"]
  type        = list(any)
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(any)
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
  type        = list(any)
}

variable "aws_ecs_cluster_name" {
  default = "ea-deploy-cluster"
}

variable "ecs_container_name-fe" {
  default = "ea-deploy-fe"
}

variable "ecs_container_name-be" {
  default = "ea-deploy-be"
}

variable "ecs_image_id-fe" {
  default = "eadeploy-fe"
}

variable "ecs_image_id-be" {
  default = "eadeploy-be"
}

variable "ecs_fe_port" {
  default = 22137
}

variable "ecs_be_port" {
  default = 2000
}

variable "aws_ecs_service_name-FE" {
  default = "eadeploy-fe"
}

variable "aws_ecs_service_name-BE" {
  default = "eadeploy-be"
}

variable "aws_alb_name" {
  default = "eadeploy-lb"
}

variable "aws_alb_fe_tg_name" {
  default = "fe-tg"
}

variable "aws_alb_fe_tg_port" {
  default = 22137
}

variable "aws_alb_fe_tg_protocol" {
  default = "HTTP"
}

variable "ecr_repo_name_fe" {
  default = "ea-deploy-fe"
}

variable "ecr_repo_name_be" {
  default = "ea-deploy-be"
}

variable "codepipeline_s3_bucket" {
  default = "morganmc-eadeploy-bucket"
}

variable "codebuild_project_name_fe" {
  default = "eadeploy-project-fe"
}

variable "codebuild_project_name_be" {
  default = "eadeploy-project-be"
}

variable "github_path" {
  default = "https://github.com/morganmcel/EADeployCA2.git"
}

variable "ecr_scanning" {
  default = false
}