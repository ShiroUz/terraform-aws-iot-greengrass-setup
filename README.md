# AWS IoT Greengrass Setup Terraform Module

[![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D1.5.7-blue.svg)](https://www.terraform.io/downloads.html)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D6.5-orange.svg)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Pre-Commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

A Terraform module for setting up AWS IoT Core and AWS IoT Greengrass infrastructure with best practices.

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

### Basic Example

```hcl
module "iot_greengrass" {
  source = "git::https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup.git?ref=v1.0.0"

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
  component_artifact_location = "arn:aws:s3:::my-greengrass-bucket/*"

  # Environment configuration
  region = "ap-northeast-1"
  env    = "prod"
}
```

### Complete Example

See the [complete example](./examples/complete) for a full configuration including custom policies and additional features.

### Using with Terraform Registry (Future)

Once published to the Terraform Registry:

```hcl
module "iot_greengrass" {
  source  = "ShiroUz/iot-greengrass-setup/aws"
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

## Examples

- [Complete](./examples/complete) - Complete example with custom policies and all features

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | >= 6.5 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.5 |

## Prerequisites

- AWS credentials properly configured
- S3 bucket for Greengrass component artifacts (if using Greengrass deployments)
- Appropriate IAM permissions to create:
  - IoT Things, Thing Groups, Certificates, Policies
  - IAM Roles and Policies
  - Systems Manager Parameters

## Version Management

This module follows [Semantic Versioning](https://semver.org/).

- **Major version**: Breaking changes
- **Minor version**: New features (backward compatible)
- **Patch version**: Bug fixes

Latest release information can be found at [Releases](https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup/releases).

## Important Notes

- The `./parent` directory contains a separate submodule for creating parent Thing Groups independently
- Role Alias and IAM role are created as shared resources when the first Thing is created
- All subsequent Things reuse the same Role Alias and IAM Role
- Certificates are stored encrypted in AWS Systems Manager Parameter Store with path: `/greengrass/${env}/${thing_name}/`
- Setting `things_amount` to 0 will not create any Thing-related resources
- Always specify a tag or version when referencing this module in production

## Releasing

This module uses automated semantic versioning for releases.

### Automatic Releases (Recommended)

Releases are automatically created when changes are merged to the `main` branch, based on commit messages following [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` triggers a **minor** version bump (e.g., 1.0.0 → 1.1.0)
- `fix:` triggers a **patch** version bump (e.g., 1.0.0 → 1.0.1)
- `BREAKING CHANGE:` in commit body triggers a **major** version bump (e.g., 1.0.0 → 2.0.0)

Example commit messages:
```bash
feat: add support for custom certificates
fix: correct IAM policy permissions
feat!: change variable names (BREAKING CHANGE)
```

### Manual Releases

You can also create releases manually through GitHub Actions:

1. Go to **Actions** → **Tag Release**
2. Click **Run workflow**
3. Enter the version number (e.g., 1.0.0)
4. Select release type (major/minor/patch)
5. Click **Run workflow**

## Development

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.7
- [terraform-docs](https://terraform-docs.io/) >= 0.16
- [TFLint](https://github.com/terraform-linters/tflint) >= 0.44
- [pre-commit](https://pre-commit.com/) >= 3.0

### Setup

```bash
# Install pre-commit hooks
make pre-commit-install

# Format code
make fmt

# Validate configuration
make validate

# Run linting
make lint

# Generate documentation
make docs

# Run all checks
make all
```

### CI/CD

This project includes GitHub Actions workflows for:

- **CI**: Runs on PRs and pushes to validate Terraform code
- **Release**: Automatically creates releases based on conventional commits
- **Tag Release**: Manual workflow for creating releases

## Contributing

Contributions are welcome! Please ensure:

1. Code is formatted with `terraform fmt`
2. All pre-commit hooks pass
3. Documentation is updated (automatically generated with terraform-docs)
4. Examples are provided for new features

## License

Apache 2.0 Licensed. See [LICENSE](./LICENSE) for full details.

## Authors

Created and maintained by [ShiroUz](https://github.com/ShiroUz).
