################################################################################
# Greengrass / Role Alias Configuration
################################################################################

variable "credential_duration" {
  description = "Duration in seconds for temporary credentials issued by the Role Alias. Valid range: 900-3600 seconds"
  type        = number
  default     = 3600
}

variable "component_artifact_location" {
  description = "S3 ARN for Greengrass component artifacts (e.g., 'arn:aws:s3:::my-bucket/*'). Required for Greengrass deployments"
  type        = string
  default     = null
}

variable "extra_iot_policy_statement" {
  description = "Additional policy statements to add to the IoT policy. Use to grant custom IoT permissions (e.g., publish/subscribe to specific topics)"
  type        = any
  default     = null
}

variable "extra_policy_statement" {
  description = "Additional IAM policy statements for the Greengrass role. Use to grant custom AWS service permissions (e.g., S3, DynamoDB, Lambda)"
  type        = any
  default     = null
}

################################################################################
# Thing Group Configuration
################################################################################

variable "thing_group_parent_name" {
  description = "Name of the parent Thing Group. This must be created separately (e.g., using the ./parent module)"
  type        = string
  default     = null
}

variable "thing_group_child_name" {
  description = "Name of the child Thing Group to create. Will be nested under the parent Thing Group"
  type        = string
  default     = null
}

variable "thing_group_attributes" {
  description = "Key-value pairs for Thing Group attributes. Used for organizing and categorizing devices"
  type        = map(string)
  default     = {}

  # Example:
  # thing_group_attributes = {
  #   Environment = "production"
  #   Team        = "iot-team"
  #   Project     = "greengrass-poc"
  #   Version     = "1.0.0"
  # }
}

variable "description" {
  description = "Description of the Thing Group. Helps document the purpose and scope of the group"
  type        = string
  default     = null
}

################################################################################
# Things Configuration
################################################################################

variable "things_base_name" {
  description = "Base name for IoT Things. Will be suffixed with index (e.g., 'sensor' becomes 'sensor-0-thing', 'sensor-1-thing', etc.)"
  type        = string
  default     = ""
}

variable "things_amount" {
  description = "Number of IoT Things to create. Set to 0 to skip Thing creation. Each Thing gets its own certificate and is added to the child Thing Group"
  type        = number
  default     = 0
}

variable "things_type_name" {
  description = "Optional Thing Type name to associate with created Things. Used for categorizing devices by their capabilities"
  type        = string
  default     = null
}

################################################################################
# Environment Configuration
################################################################################

variable "region" {
  description = "AWS region where IoT resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment name (e.g., 'dev', 'staging', 'prod'). Used for resource naming and tagging"
  type        = string
  default     = "dev"
}
