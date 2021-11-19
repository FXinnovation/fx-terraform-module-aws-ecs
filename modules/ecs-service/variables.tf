variable "cluster_id" {
  description = "ECS cluster id."
  type        = string
}

variable "cluster_sg" {
  description = "ID of the ECS ASG security group"
  type        = string
}

variable "service_name" {
  description = "ECS service name."
  type        = string
}

variable "task_count" {
  description = "Number of task replicas to spawn."
  type        = string
}

variable "service_platform_version" {
  description = "ECS platform version for container engine."
  type        = string
  default     = "LATEST"
}

variable "task_definition_name" {
  description = "ECS task definition name for a single or group of containers."
  type        = string
}

variable "task_cpu_value" {
  description = "Number of cpu units allocated for tasks."
}

variable "task_mem_value" {
  description = "Number of mem units allocated for tasks."
}

variable "task_network_mode" {
  description = "ECS task container network mode."
  type        = string
  default     = "awsvpc"
}

variable "vpc_id" {
  description = "VPC identifier."
  type        = string
}

variable "container_name" {
  description = "ECS container name."
  type        = string
}

variable "container_image" {
  description = "ECS container image to pull."
  type        = string
}

variable "container_cpu_limit" {
  description = "ECS container cpu usage limit."
  type        = number
}

variable "container_mem_limit" {
  description = "ECS container memory usage limit."
  type        = number
}

variable "container_inside_port" {
  description = "ECS container inside port."
  type        = number
}

variable "container_outside_port" {
  description = "ECS container outside port to map on host."
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for ESB deployment."
  type        = list(any)
}

variable "lb_enabled" {
  description = "Whether or not a load balancer should be used."
  type        = bool
}

variable "lb_target_group_arn" {
  type        = string
  description = "Target group ARN"
  default     = null
}

variable "launch_type" {
  description = "Type of support for launching the containers. Must be one of EC2 or FARGATE."
  type        = string
  default     = "EC2"
}

variable "scheduling_strategy" {
  description = "Scheduling strategy for the task."
  type        = string
  default     = "REPLICA"
}

variable "environment_map" {
  description = "List of maps containing the environment variables to inject in the container."
  type        = list(map(string))
}

variable "secret_map" {
  description = "List of maps containing aws secrets to inject as environment variables in the container."
  type        = list(map(string))
}

variable "apache_auth_secret_map" {
  description = "List of maps containing aws secrets to inject as environment variables in the container."
  type        = list(map(string))
  default     = []
}

variable "command" {
  description = "Command to launch on container startup."
  type        = string
  default     = "start.sh"
}

variable "port_mappings" {
  description = "List of maps containing the port mappings for the container."
  type = list(object({
    containerPort = number
  }))
}

variable "container_healthcheck_path" {
  description = "Endpoint to use for the healthcheck of the container"
  type        = string
  default     = "/"
}

variable "container_healthcheck_code" {
  description = "Health check status code to use for the container"
  type        = number
  default     = 200
}

variable "enable_logs" {
  description = "Enable CloudWatch logs for ECS."
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  type        = number
  default     = 50
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the DAEMON scheduling strategy."
  type        = number
  default     = 200
}

variable "enable_circuit_breaker" {
  description = "Whether to enable the deployment circuit breaker logic for the service."
  type        = bool
  default     = true
}

variable "enable_circuit_breaker_rollback" {
  description = "Whether to enable Amazon ECS to roll back the service if a service deployment fails. If rollback is enabled, when a service deployment fails, the service is rolled back to the last deployment that completed successfully."
  type        = bool
  default     = true
}
