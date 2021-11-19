


# data "aws_iam_policy" "this" {
#   name = "AmazonEC2ContainerServiceforEC2Role"
# }

# resource "aws_iam_role" "this" {
#   name = "ecsInstanceRole-${var.environment}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })

#   managed_policy_arns = [data.aws_iam_policy.this.arn]
# }

# resource "aws_security_group" "this" {
#   name        = "${local.app_name}-App"
#   description = "${local.app_name}-App"
#   vpc_id      = var.vpc_id
# }


# data "template_file" "this" {
#   template = file("${path.module}/userdata.tpl")
#   vars = {
#     ecs_cluster = var.ecs_cluster_name
#   }
# }

# resource "aws_iam_instance_profile" "this" {
#   name = aws_iam_role.this.name
#   role = aws_iam_role.this.name
# }

# data "aws_ami" "this" {
#   most_recent = true

#   filter {
#     name = "name"
#     values = ["amzn2-ami-ecs-hvm-2.0.????????-x86_64-ebs"]
#   }

#   owners = ["amazon"]
# }

# resource "random_id" "this" {
#   keepers = {
#     image_id = data.aws_ami.this.image_id
#   }

#   byte_length = 4
# }

# resource "aws_launch_configuration" "this" {
#   name                  = "${local.app_name}-ECS-${random_id.this.hex}"
#   image_id              = random_id.this.keepers.image_id
#   instance_type         = var.ecs_instance_type
#   iam_instance_profile  = aws_iam_instance_profile.this.arn
#   enable_monitoring     = true
#   user_data             = data.template_file.this.rendered
#   security_groups       = [aws_security_group.this.id]

#   lifecycle { create_before_destroy = true }
# }

# resource "aws_autoscaling_group" "this" {
#   name                  = "ECSContainerService-${local.app_name}-${aws_launch_configuration.this.name}-ASG"
#   vpc_zone_identifier   = var.ecs_subnet_ids
#   desired_capacity      = var.ecs_desired_capacity
#   max_size              = var.ecs_max_size
#   min_size              = var.ecs_min_size
#   launch_configuration  = aws_launch_configuration.this.name
#   tags                  = [{
#     key = "Name"
#     value = "ECS Instance - EC2ContainerService-${local.app_name}-ECS"
#     propagate_at_launch = true
#   }]

#   lifecycle { create_before_destroy = true }
# }

# resource "aws_security_group" "this" {
#   name        = "${local.app_name}-App"
#   description = "${local.app_name}-App"
#   vpc_id      = var.vpc_id
# }
