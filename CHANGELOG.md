## [Unreleased]

## [1.0.0] - 2025-10-12

## What's Changed

## 🚀 Features

- feat: update README.md (#1) @ShiroUz

## 📝 Documentation

- feat: update README.md (#1) @ShiroUz

## Installation

```hcl
module "iot_greengrass" {
  source = "git::https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup.git?ref=1.0.0"

  # Your configuration here
}
```

## Full Changelog

**Full Changelog**: https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup/compare/...1.0.0


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial module structure
- Support for AWS IoT Thing Groups (parent and child)
- Support for multiple AWS IoT Things creation
- Automatic IoT certificate generation
- IAM Role and Role Alias creation for Greengrass
- IoT policy configuration
- Certificate storage in AWS Systems Manager Parameter Store
- AWS IoT Greengrass support
- Submodule structure for Things management

### Documentation
- Initial README with usage examples
- Variable and output documentation

## [1.0.0] - YYYY-MM-DD

### Added
- First stable release

[Unreleased]: https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup/releases/tag/v1.0.0

[Unreleased]: https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup/releases/tag/v1.0.0
