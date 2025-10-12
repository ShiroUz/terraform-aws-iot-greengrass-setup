# Contributing to AWS IoT Greengrass Setup Terraform Module

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following tools installed:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.7
- [terraform-docs](https://terraform-docs.io/) >= 0.16
- [TFLint](https://github.com/terraform-linters/tflint) >= 0.44
- [pre-commit](https://pre-commit.com/) >= 3.0
- [GNU Make](https://www.gnu.org/software/make/)

### Setup Development Environment

1. Fork and clone the repository:
```bash
git clone https://github.com/ShiroUz/terraform-aws-iot-greengrass-setup.git
cd terraform-aws-iot-greengrass-setup
```

2. Install pre-commit hooks:
```bash
make pre-commit-install
```

3. Make your changes and ensure all checks pass:
```bash
make all
```

## Development Workflow

### Making Changes

1. Create a new branch for your feature or bugfix:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes following the coding standards below

3. Test your changes:
```bash
# Format code
make fmt

# Validate Terraform
make validate

# Run linting
make lint

# Generate documentation
make docs

# Test examples
make test-examples
```

4. Commit your changes with a descriptive message:
```bash
git commit -m "feat: add support for custom certificates"
```

## Coding Standards

### Terraform Style Guide

- Use consistent formatting with `terraform fmt`
- Follow [HashiCorp's Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Use meaningful variable and resource names
- Keep resources organized and grouped logically

### Variable Definitions

- All variables must have:
  - A `type` declaration
  - A `description` explaining its purpose
  - A `default` value (if optional)

Example:
```hcl
variable "example_var" {
  description = "Clear description of what this variable does and when to use it"
  type        = string
  default     = "default-value"
}
```

### Output Definitions

- All outputs must have a `description`
- Mark outputs as `sensitive = true` if they contain credentials or secrets

Example:
```hcl
output "example_output" {
  description = "Description of what this output represents"
  value       = aws_resource.example.id
}
```

### Documentation

- Update README.md if you add new features or change behavior
- Use terraform-docs to auto-generate variable and output tables
- Add examples for new features in the `examples/` directory
- Include inline comments for complex logic

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

## Pre-commit Hooks

This project uses pre-commit hooks to ensure code quality:

- `terraform_fmt` - Format Terraform files
- `terraform_validate` - Validate Terraform configuration
- `terraform_docs` - Generate documentation
- `terraform_tflint` - Lint Terraform code
- `terraform_checkov` - Security scanning

All hooks must pass before code can be committed.

## Testing

### Manual Testing

1. Test in the examples directory:
```bash
cd examples/complete
terraform init
terraform plan
```

2. Ensure no errors or warnings

### Validation Checklist

Before submitting a PR, ensure:

- [ ] Code is formatted with `terraform fmt`
- [ ] Terraform validation passes
- [ ] TFLint shows no errors
- [ ] Documentation is updated
- [ ] Examples work correctly
- [ ] CHANGELOG.md is updated (for significant changes)
- [ ] All pre-commit hooks pass

## Submitting Changes

### Pull Request Process

1. Push your changes to your fork:
```bash
git push origin feature/your-feature-name
```

2. Create a Pull Request with:
   - Clear title describing the change
   - Description of what changed and why
   - References to related issues
   - Screenshots (if applicable)

3. Ensure CI checks pass

4. Address review comments

5. Once approved, a maintainer will merge your PR

### PR Requirements

- All CI checks must pass
- At least one approval from a maintainer
- No unresolved conversations
- Branch is up to date with main

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **Major version** (X.0.0): Breaking changes
- **Minor version** (0.X.0): New features (backward compatible)
- **Patch version** (0.0.X): Bug fixes

## Questions?

Feel free to:
- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas
- Contact the maintainers

## Code of Conduct

Be respectful and professional. We're all here to build better software together.

## License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 License.
