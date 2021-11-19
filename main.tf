locals {
  tags = {
    "Terraform" = "true"
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

resource "aws_security_group" "this" {
  name        = "${var.ecs_cluster_name}-sg"
  description = "${var.ecs_cluster_name} security group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.tags,
  )
}

#####
# Services
#####

module "service" {
  source = "./modules/ecs-service"

  for_each = var.service

  cluster_id               = aws_ecs_cluster.this.id
  cluster_sg               = aws_security_group.this.id
  launch_type              = var.ecs_launch_type
  scheduling_strategy      = var.ecs_scheduling_strategy
  service_platform_version = var.ecs_service_platform_version
  subnet_ids               = var.subnet_ids
  vpc_id                   = var.vpc_id

  apache_auth_secret_map             = lookup(each.value, "ecs_apache_auth_secret_map", [])
  command                            = lookup(each.value, "ecs_command", null)
  container_cpu_limit                = lookup(each.value, "ecs_container_cpu_limit", null)
  container_healthcheck_path         = lookup(each.value, "ecs_container_healthcheck_path", "/")
  container_image                    = lookup(each.value, "ecs_container_image", null)
  container_inside_port              = lookup(each.value, "ecs_container_inside_port", null)
  container_mem_limit                = lookup(each.value, "ecs_container_mem_limit", null)
  container_name                     = lookup(each.value, "ecs_container_name", null)
  container_outside_port             = lookup(each.value, "ecs_container_outside_port", null)
  deployment_maximum_percent         = lookup(each.value, "ecs_deployment_maximum_percent", 200)
  deployment_minimum_healthy_percent = lookup(each.value, "ecs_deployment_minimum_healthy_percent", 50)
  enable_circuit_breaker             = lookup(each.value, "ecs_enable_circuit_breaker", true)
  enable_circuit_breaker_rollback    = lookup(each.value, "ecs_enable_circuit_breaker_rollback", true)
  environment_map                    = lookup(each.value, "ecs_environment_map", [])
  lb_enabled                         = lookup(each.value, "ecs_lb_enabled", false)
  lb_target_group_arn                = lookup(each.value, "ecs_lb_target_group_arn", null)
  port_mappings                      = lookup(each.value, "ecs_port_mappings", [])
  secret_map                         = lookup(each.value, "ecs_secret_map", [])
  service_name                       = lookup(each.value, "ecs_service_name", null)
  task_count                         = lookup(each.value, "ecs_task_count", null)
  task_cpu_value                     = lookup(each.value, "ecs_task_cpu_value", null)
  task_definition_name               = lookup(each.value, "ecs_task_definition_name", null)
  task_mem_value                     = lookup(each.value, "ecs_container_mem_limit", null)
  task_network_mode                  = lookup(each.value, "ecs_task_network_mode", null)
  enable_logs                        = lookup(each.value, "ecs_enable_logs", true)
}
