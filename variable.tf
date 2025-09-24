# Role Alias
variable "credential_duration" {
  type    = number
  default = 3600
}

variable "component_artifact_location" {
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

variable "thing_group_attributes" {
  type        = map(string)
  default     = {}
  description = "Key-value pairs for Thing Group attributes"
  
  # Example:
  # thing_group_attributes = {
  #   Environment = "production"
  #   Team        = "iot-team"
  #   Project     = "greengrass-poc"
  #   Version     = "1.0.0"
  # }
}

variable "description" {
  type    = string
  default = null
}

# Things
variable "things_base_name" {
  type    = string
  default = ""
}

variable "things_amount" {
  type    = number
  default = 0
}

variable "things_type_name" {
  type    = string
  default = null
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
