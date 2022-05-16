resource "aws_ecs_cluster" "cluster" {
  name               = var.aws_ecs_cluster_name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.eadeploy_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_logging.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_logging" {
  name = "ecs_logging"
}
resource "aws_kms_key" "eadeploy_key" {
  description             = "eadeploy_key"
  deletion_window_in_days = 7
}

resource "aws_ecs_task_definition" "frontend" {
  family = "service"
  requires_compatibilities = [
    "FARGATE",
  ]
  execution_role_arn = aws_iam_role.fargate.arn
  network_mode       = "awsvpc"
  cpu                = 1024
  memory             = 2048
  container_definitions = jsonencode([
    {
      name  = var.ecs_container_name-fe
      image = "019359575870.dkr.ecr.eu-west-1.amazonaws.com/ea-deploy-fe:350c032"

      essential = true
      portMappings = [
        {
          containerPort = var.ecs_fe_port
          hostPort      = var.ecs_fe_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "eadeploy-ecs-service" {
  name            = var.aws_ecs_service_name-FE
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnet_ids.private.ids
    assign_public_ip = false
    security_groups  = ["${aws_security_group.container_access.id}"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fe-tg.arn
    container_name   = var.ecs_container_name-fe
    container_port   = var.ecs_fe_port
  }
  deployment_controller {
    type = "ECS"
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }
  service_registries {
    registry_arn = aws_service_discovery_service.eadeploy-service-frontend.arn
  }

  depends_on = [aws_lb_target_group.fe-tg]
}

########### Backend

resource "aws_ecs_task_definition" "backend" {
  family = "service"
  requires_compatibilities = [
    "FARGATE",
  ]
  execution_role_arn = aws_iam_role.fargate.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  container_definitions = jsonencode([
    {
      name  = var.ecs_container_name-be
      image = "019359575870.dkr.ecr.eu-west-1.amazonaws.com/ea-deploy-be:c7ae9df"

      essential = true
      portMappings = [
        {
          containerPort = var.ecs_be_port
          hostPort      = var.ecs_be_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "eadeploy-ecs-service-be" {
  name            = var.aws_ecs_service_name-BE
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnet_ids.private.ids
    assign_public_ip = false
    security_groups  = ["${aws_security_group.container_access.id}"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.be-tg.arn
    container_name   = var.ecs_container_name-be
    container_port   = var.ecs_be_port
  }
  health_check_grace_period_seconds = 120
  deployment_controller {
    type = "ECS"
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }
  service_registries {
    registry_arn = aws_service_discovery_service.eadeploy-service-backend.arn
  }
}
resource "aws_service_discovery_private_dns_namespace" "eadeploy-internal-namespace" {
  name        = "eadeploy-internal-namespace"
  description = "eadeploy internal DNS namespace"
  vpc         = aws_vpc.eadeploy-vpc.id
}

resource "aws_service_discovery_service" "eadeploy-service-frontend" {
  name = "ead-service-frontend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.eadeploy-internal-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "eadeploy-service-backend" {
  name = "ead-service-backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.eadeploy-internal-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}