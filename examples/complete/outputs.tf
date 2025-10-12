output "thing_group_child_arn" {
  description = "ARN of the child Thing Group"
  value       = module.iot_greengrass.thing_group_child_arn
}

output "role_alias_arn" {
  description = "ARN of the IoT Role Alias for Greengrass"
  value       = module.iot_greengrass.role_alias_arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by Greengrass"
  value       = module.iot_greengrass.iam_role_arn
}

output "things" {
  description = "Information about all created IoT Things"
  value       = module.iot_greengrass.things
  sensitive   = true
}

output "thing_names" {
  description = "List of created Thing names"
  value       = [for thing in module.iot_greengrass.things : thing.thing_name]
}

output "thing_arns" {
  description = "List of created Thing ARNs"
  value       = [for thing in module.iot_greengrass.things : thing.thing_arn]
}
