resource "random_pet" "this" {
  length = 2
}

resource "aws_ecs_cluster" "this" {
  name = "ecs-test-${random_pet.this.id}"

  tags = merge(
    local.tags,
    var.tags,
  )
}

resource "aws_security_group" "this" {
  name        = "${aws_ecs_cluster.this.name}-sg"
  description = "${aws_ecs_cluster.this.name} security group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "ecs" {
  source = "../../"

  cluster_id       = aws_ecs_cluster.this.id
  cluster_sg       = aws_security_group.this.id
  ecs_cluster_name = aws_ecs_cluster.this.name
  vpc_id           = data.aws_vpc.default.id
  subnet_ids       = tolist(data.aws_subnet_ids.default.ids)
  service = {
    nginx = {
      "ecs_launch_type" : "FARGATE"
      "ecs_lb_enabled" : false
      "ecs_task_network_mode" : "awsvpc"
      "ecs_task_cpu_value" : 125
      "ecs_service_name" : "nginx"
      "ecs_container_inside_port" : 80
      "ecs_container_outside_port" : 80
      "ecs_task_count" : 1
      "ecs_container_name" : "nginx"
      "ecs_task_definition_name" : "nginx"
      "ecs_container_image" : "nginx:latest"
      "ecs_container_cpu_limit" : 125
      "ecs_container_mem_limit" : 64
      "ecs_deployment_minimum_healthy_percent" : 50
      "ecs_deployment_maximum_percent" : 200
      "ecs_lb_enabled" : true
      "ecs_lb_target_group_arn" : module.alb.target_group_arns[0]
      "ecs_port_mappings" : [
        {
          "containerPort" : 80
        }
      ]
    }
  }
}

resource "aws_security_group_rule" "this_app_ingress_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.this.id
  security_group_id        = module.ecs.cluster_sg_id
}

module "alb" {
  source = "git::https://scm.dazzlingwrench.fxinnovation.com/fxinnovation-public/terraform-aws-alb.git?ref=v6.5.0"

  name = "test-alb-${random_pet.this.id}"

  load_balancer_type = "application"

  internal        = false
  vpc_id          = data.aws_vpc.default.id
  security_groups = [aws_security_group.this.id]
  subnets         = tolist(data.aws_subnet_ids.default.ids)

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
    },
  ]
}
