variable "things_name" {
  type = string
}

variable "thing_group_child_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "account_name" {
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

variable "extra_policy_statement" {
  type    = any
  default = null
}