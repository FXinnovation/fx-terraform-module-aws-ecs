data "aws_region" "current" {}

locals {
  tags = {
    "Terraform" = "true"
  }
  logConfiguration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "/ecs/${var.task_definition_name}"
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

####
# IAM
####

resource "aws_iam_role" "this" {
  name = "ecs-${var.service_name}-service-iam-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": [
                 "ecs-tasks.amazonaws.com"
               ]
            },
            "Effect": "Allow",
            "Sid": ""

        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "ecs-service-${var.service_name}-iam-role-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Get*",
          "kms:Decrypt*",
          "secretsmanager:GetSecretValue",
          "s3:Get*",
          "s3:List*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ssm:GetParameter*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

####
# ECS
####


resource "aws_ecs_service" "this" {
  name    = var.service_name
  cluster = var.cluster_id

  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.task_count

  launch_type         = var.launch_type
  scheduling_strategy = var.scheduling_strategy
  platform_version    = var.launch_type == "FARGATE" ? var.service_platform_version : null

  dynamic "load_balancer" {
    for_each = !var.lb_enabled ? [] : [var.lb_target_group_arn]
    content {
      target_group_arn = load_balancer.value
      container_name   = var.container_name
      container_port   = var.container_inside_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.task_network_mode != "awsvpc" ? [] : [1]
    content {
      security_groups  = [var.cluster_sg]
      subnets          = var.subnet_ids
      assign_public_ip = true
    }
  }
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.enable_circuit_breaker_rollback
  }

  tags = merge(
    local.tags,
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.enable_logs ? 1 : 0
  name  = "/ecs/${var.task_definition_name}"
}

resource "aws_ecs_task_definition" "this" {
  family = var.task_definition_name
  container_definitions = jsonencode([
    {
      name             = var.container_name
      image            = var.container_image
      cpu              = var.container_cpu_limit
      memory           = var.container_mem_limit
      essential        = true
      portMappings     = var.port_mappings
      command          = [var.command]
      environment      = var.environment_map
      secrets          = var.secret_map
      logConfiguration = var.enable_logs ? local.logConfiguration : null
    }
  ])
  requires_compatibilities = [var.launch_type]
  cpu                      = var.task_cpu_value
  memory                   = var.task_mem_value
  network_mode             = var.task_network_mode
  execution_role_arn       = aws_iam_role.this.arn
  tags                     = merge(local.tags, var.tags)
}
