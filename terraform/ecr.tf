resource "aws_ecr_repository" "fe-repository" {
  name                 = var.ecr_repo_name_fe
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = var.ecr_scanning
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key = var.kms_key
  }
}

resource "aws_ecr_repository_policy" "ead-ecr-fe-policy" {
  repository = aws_ecr_repository.fe-repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the ${var.ecr_repo_name_fe} repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository" "be-repository" {
  name                 = var.ecr_repo_name_be
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = var.ecr_scanning
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key = var.kms_key
  }
}

resource "aws_ecr_repository_policy" "ead-ecr-be-policy" {
  repository = aws_ecr_repository.be-repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the ${var.ecr_repo_name_fe} repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}
