variable "things_base_name" {
  type = string
}

variable "things_number" {
  type = number
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

variable "secret_version" {
  type    = number
  default = 1
}

variable "enable_greengrass" {
  type    = bool
  default = false
}

variable "role_alias_name" {
  type = string
}

variable "credential_duration" {
  type    = number
  default = 3600
}

variable "component_artifact_location" {
  type = string
}

variable "role_name" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "extra_policy_statement" {
  type    = any
  default = null
}