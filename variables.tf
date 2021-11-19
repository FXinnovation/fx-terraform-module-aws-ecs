variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "ecs_service_platform_version" {
  description = "ECS platform version for container engine."
  type        = string
  default     = "LATEST"
}

variable "vpc_id" {
  description = "VPC identifier."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ESB deployment."
  type        = list(any)
}

variable "ecs_launch_type" {
  description = "Type of support for launching the containers. Must be one of EC2 or FARGATE."
  type        = string
  default     = "FARGATE"
}

variable "ecs_scheduling_strategy" {
  description = "Scheduling strategy for the task."
  type        = string
  default     = "REPLICA"
}

variable "service" {
  description = "Map of maps containing the definition of the services to deploy in ecs."
  type        = map(any)
  default     = {}
}

variable "tags" {
  type = map(string)
  default = {}
}
