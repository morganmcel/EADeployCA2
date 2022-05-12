resource "aws_ecs_cluster" "cluster" {
  name               = var.aws_ecs_cluster_name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }
}

resource "aws_ecs_task_definition" "task" {
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
      name      = var.ecs_container_name-fe
      image     = var.ecs_image_id-fe
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

resource "aws_ecs_service" "service" {
  name            = var.aws_ecs_service_name-FE
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
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
  depends_on = [aws_lb_target_group.fe-tg]
}
