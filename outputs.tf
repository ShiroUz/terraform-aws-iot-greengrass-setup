output "role_alias_arn" {
  value = length(module.things) > 0 ? module.things[0].role_alias_arn : null
}

output "iam_role_arn" {
  value = length(module.things) > 0 ? module.things[0].iam_role_arn : null
}

output "thing_group_child_arn" {
  value = aws_iot_thing_group.child.arn
}

output "things" {
  value = module.things[*]
}