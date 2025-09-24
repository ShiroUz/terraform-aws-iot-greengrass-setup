output "thing_name" {
  value = aws_iot_thing.this.name
}

output "thing_arn" {
  value = aws_iot_thing.this.arn
}

output "certificate_arn" {
  value = aws_iot_certificate.this.arn
}

output "role_alias_arn" {
  value = aws_iot_role_alias.this.arn
}

output "iam_role_arn" {
  value = aws_iam_role.role.arn
}