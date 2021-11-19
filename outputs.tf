output "cluster_sg_id" {
  value = element(concat(aws_security_group.this.*.id, [""]), 0)
}
