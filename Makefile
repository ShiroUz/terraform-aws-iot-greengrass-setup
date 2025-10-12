.PHONY: help fmt validate lint docs pre-commit-install pre-commit-run clean

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive .

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@terraform init -backend=false
	@terraform validate

lint: ## Run TFLint
	@echo "Running TFLint..."
	@tflint --init
	@tflint --recursive

docs: ## Generate documentation with terraform-docs
	@echo "Generating documentation..."
	@terraform-docs markdown table --output-file README.md --output-mode inject .
	@terraform-docs markdown table --output-file examples/complete/README.md --output-mode inject examples/complete/

pre-commit-install: ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	@pre-commit install

pre-commit-run: ## Run pre-commit hooks on all files
	@echo "Running pre-commit hooks..."
	@pre-commit run --all-files

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -type f -name "terraform.tfstate*" -delete 2>/dev/null || true
	@echo "Clean complete"

test-examples: ## Test example configurations
	@echo "Testing examples..."
	@cd examples/complete && terraform init && terraform validate
	@echo "Examples validation complete"

all: fmt validate lint docs ## Run all checks (format, validate, lint, docs)
