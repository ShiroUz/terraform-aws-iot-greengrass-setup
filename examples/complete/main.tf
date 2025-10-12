provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-1"
  env    = "production"

  thing_group_parent_name = "production-devices"
  thing_group_child_name  = "sensor-devices"
  things_base_name        = "sensor"
  things_amount           = 3

  tags = {
    Environment = local.env
    Project     = "IoT-Greengrass-Example"
    ManagedBy   = "Terraform"
  }
}

################################################################################
# IoT Greengrass Complete Example
################################################################################

module "iot_greengrass" {
  source = "../.."

  # Thing Group configuration
  thing_group_parent_name = local.thing_group_parent_name
  thing_group_child_name  = local.thing_group_child_name
  description             = "Production IoT sensor devices with Greengrass"
  thing_group_attributes = {
    Environment = local.env
    Team        = "iot-platform"
    Project     = "sensor-monitoring"
    CostCenter  = "engineering"
  }

  # Things configuration
  things_base_name = local.things_base_name
  things_amount    = local.things_amount
  things_type_name = "SensorDevice"

  # Greengrass configuration
  component_artifact_location = "arn:aws:s3:::my-greengrass-components-bucket/*"
  credential_duration         = 3600

  # Additional IoT policy statements
  extra_iot_policy_statement = [
    {
      Effect = "Allow"
      Action = [
        "iot:Subscribe"
      ]
      Resource = [
        "arn:aws:iot:${local.region}:*:topicfilter/sensor/*"
      ]
    },
    {
      Effect = "Allow"
      Action = [
        "iot:Receive"
      ]
      Resource = [
        "arn:aws:iot:${local.region}:*:topic/sensor/*"
      ]
    }
  ]

  # Additional IAM policy statements for Greengrass
  extra_policy_statement = [
    {
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:${local.region}:*:log-group:/aws/greengrass/*"
    }
  ]

  # Environment configuration
  region = local.region
  env    = local.env
}
