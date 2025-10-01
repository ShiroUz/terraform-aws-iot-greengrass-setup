variable "things_name" {
  type = string
}

variable "things_type_name" {
  type    = string
  default = null
}

variable "thing_group_child_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "credential_duration" {
  type    = number
  default = 3600
}

variable "component_artifact_location" {
  type = string
}
variable "extra_iot_policy_statement" {
  type    = any
  default = null
}

variable "extra_policy_statement" {
  type    = any
  default = null
}