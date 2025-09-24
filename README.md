# AWS IoT Greengrass Setup Terraform Module

A Terraform module for setting up AWS IoT Core and AWS IoT Greengrass infrastructure.

## Features

- Create AWS IoT Thing Groups (parent and child)
- Create multiple AWS IoT Things
- Automatic IoT certificate generation
- IAM Role and Role Alias creation
- IoT policy configuration
- Certificate storage in AWS Systems Manager Parameter Store
- AWS IoT Greengrass support

## Module Structure

```
terraform-aws-iot-greengrass-setup/
├── main.tf              # Main resources (Thing Groups)
├── variable.tf          # Input variable definitions
├── outputs.tf           # Output value definitions
└── things/              # Things submodule
    ├── main.tf          # Things, certificates, policies, Role Alias
    ├── variables.tf     # Submodule variables
    └── outputs.tf       # Submodule outputs
```

## Usage

### Git Repository Reference

```hcl
module "iot_greengrass" {
  source = "git::https://github.com/your-org/terraform-aws-iot-greengrass-setup.git?ref=v1.0.0"

  # Thing Group configuration
  thing_group_parent_name = "production-devices"
  thing_group_child_name  = "sensors"
  description             = "IoT sensor devices"
  thing_group_attributes = {
    Environment = "production"
    Team        = "iot-team"
    Project     = "sensor-monitoring"
  }

  # Things configuration
  things_base_name = "sensor-device"
  things_amount    = 3

  # Greengrass configuration
  component_artifact_location = "arn:aws:s3:::my-greengrass-bucket"
  # Environment configuration
  region = "ap-northeast-1"
  env    = "prod"
}
```

### HCP Terraform Registry (Planned)

```hcl
module "iot_greengrass" {
  source  = "your-org/iot-greengrass-setup/aws"
  version = "~> 1.0"

  # Same configuration as above
}
```

## Input Variables

### Thing Group Related
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `thing_group_parent_name` | string | null | Parent Thing Group name |
| `thing_group_child_name` | string | null | Child Thing Group name |
| `thing_group_attributes` | map(string) | {} | Thing Group attributes |
| `description` | string | null | Thing Group description |

### Things Related
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `things_base_name` | string | "" | Base name for Things |
| `things_amount` | number | 0 | Number of Things to create |
| `secret_version` | number | 1 | SSM parameter version |

### Greengrass Related
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `role_alias_name` | string | null | Role Alias name |
| `credential_duration` | number | 3600 | Credential duration in seconds |
| `component_artifact_location` | string | null | S3 ARN for component artifacts |
| `role_name` | string | null | IAM role name |
| `policy_name` | string | null | IAM policy name |
| `extra_policy_statement` | any | null | Additional policy statements |

### Environment Related
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `region` | string | "us-east-1" | AWS region |
| `env` | string | "dev" | Environment name |

## Outputs

| Output | Description |
|--------|-------------|
| `role_alias_arn` | Role Alias ARN |
| `iam_role_arn` | IAM role ARN |
| `thing_group_parent_arn` | Parent Thing Group ARN |
| `thing_group_child_arn` | Child Thing Group ARN |
| `things` | Information about created Things |

## Created Resources

### Main Module
- `aws_iot_thing_group` (parent/child)

### Things Submodule (created `things_amount` times)
- `aws_iot_thing`
- `aws_iot_certificate`
- `aws_iot_policy`
- `aws_iot_policy_attachment`
- `aws_iot_thing_principal_attachment`
- `aws_iot_thing_group_membership`
- `aws_ssm_parameter` (for certificate storage)

### Shared Resources (created only with the first Thing)
- `aws_iot_role_alias`
- `aws_iam_role`
- `aws_iam_policy`
- `aws_iam_role_policy_attachment`

## Requirements

- Terraform >= 1.13
- AWS Provider >= 6.0
- Proper AWS credentials configuration

## Version Management

This module follows [Semantic Versioning](https://semver.org/).

- Major version: Breaking changes
- Minor version: New features
- Patch version: Bug fixes

Latest release information can be found at [Releases](https://github.com/your-org/terraform-aws-iot-greengrass-setup/releases).

## Important Notes

- The `./parent` directory is intended to be executed separately
- Role Alias and IAM role are created as shared resources when the first Thing instance is created
- Certificates are stored encrypted in AWS Systems Manager Parameter Store
- Setting `things_amount` to 0 will not create any Thing-related resources
- Always specify a tag or commit hash when referencing Git repositories
- After HCP Terraform Registry registration, use version constraints to prevent unexpected changes

## ライセンス

MIT License