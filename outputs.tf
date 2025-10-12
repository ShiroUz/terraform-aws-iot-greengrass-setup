output "role_alias_arn" {
  description = "ARN of the IoT Role Alias created for Greengrass authentication"
  value       = length(module.things) > 0 ? module.things[0].role_alias_arn : null
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by Greengrass devices"
  value       = length(module.things) > 0 ? module.things[0].iam_role_arn : null
}

output "thing_group_child_arn" {
  description = "ARN of the child Thing Group"
  value       = aws_iot_thing_group.child.arn
}

output "things" {
  description = "List of all created Things with their properties (includes sensitive certificate data)"
  value       = module.things[*]
  sensitive   = true
}