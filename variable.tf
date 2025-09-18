# Role Alias
variable "role_alias_name" {
  type    = string
  default = null
}
variable "credential_duration" {
  type    = number
  default = 3600
}

variable "component_artifact_location" {
  type    = string
  default = null
}

variable "role_name" {
  type    = string
  default = null
}

variable "policy_name" {
  type    = string
  default = null
}

variable "extra_policy_statement" {
  type    = any
  default = null
}
# Thing Group
variable "thing_group_parent_name" {
  type    = string
  default = null
}

variable "thing_group_child_name" {
  type    = string
  default = null
}

variable "is_child" {
  type    = bool
  default = false
}

variable "thing_attributes" {
  type = list(object({
    key   = string
    value = string
    }
    )
  )
  default = null
}

variable "item" {
  type    = number
  default = 0
}

variable "description" {
  type    = string
  default = null
}

# Things
variable "things_name" {
  type    = string
  default = ""
}

variable "things_number" {
  type    = number
  default = 0
}

variable "things_type" {
  type    = string
  default = null
}

variable "secret_version" {
  type    = number
  default = 1
}



# env
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "account_name" {
  type    = string
  default = "123456789"
}

variable "enable_greengrass" {
  type    = bool
  default = false
}