## Description

<!-- Provide a brief description of the changes in this PR -->

**Note**: Please ensure your PR title follows [Conventional Commits](https://www.conventionalcommits.org/) format:
- Format: `type(scope): description`
- Example: `feat(iot): add support for custom certificates`
- Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

## Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] `feat`: New feature (non-breaking change which adds functionality)
- [ ] `fix`: Bug fix (non-breaking change which fixes an issue)
- [ ] `docs`: Documentation update
- [ ] `style`: Code style update (formatting, renaming)
- [ ] `refactor`: Code refactoring (no functional changes)
- [ ] `perf`: Performance improvement
- [ ] `test`: Adding or updating tests
- [ ] `build`: Build system or external dependencies update
- [ ] `ci`: CI configuration update
- [ ] `chore`: Other changes that don't modify src or test files
- [ ] `revert`: Revert a previous commit
- [ ] `breaking`: Contains breaking changes (mark major version bump)

## Related Issues

<!-- Link related issues here using #issue_number -->

Fixes #
Related to #

## Checklist

<!-- Mark completed items with an 'x' -->

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have run `terraform fmt` and the code is properly formatted
- [ ] I have run `terraform validate` and the configuration is valid
- [ ] I have run `make all` and all checks pass
- [ ] I have updated the CHANGELOG.md (if applicable)
- [ ] I have added/updated examples (if applicable)
- [ ] Any dependent changes have been merged and published

## Testing

<!-- Describe the tests you ran and their results -->

```bash
# Commands run for testing
terraform init
terraform validate
terraform plan
```

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## Additional Notes

<!-- Add any additional notes or context about the PR here -->
