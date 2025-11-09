.PHONY: help check init validate plan apply deploy output destroy clean format

# Default target
.DEFAULT_GOAL := help

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(BLUE)AWS ALB Terraform Makefile$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

check: ## Check prerequisites
	@./deploy.sh --check

init: ## Initialize Terraform
	@terraform init

validate: init ## Validate Terraform configuration
	@terraform fmt -recursive
	@terraform validate

plan: validate ## Create deployment plan
	@terraform plan -out=plan.out

apply: ## Apply deployment plan
	@terraform apply plan.out
	@rm -f plan.out

deploy: ## Full deployment (init + validate + plan + apply)
	@./deploy.sh --deploy

output: ## Show deployment outputs
	@terraform output

destroy: ## Destroy all infrastructure
	@./destroy.sh

clean: ## Clean Terraform files
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@rm -f plan.out
	@rm -f *.tfstate*
	@echo "$(GREEN)Cleaned Terraform files$(NC)"

format: ## Format Terraform code
	@terraform fmt -recursive
	@echo "$(GREEN)Formatted all Terraform files$(NC)"

test: validate ## Test configuration (validate + plan)
	@terraform plan

refresh: ## Refresh Terraform state
	@terraform refresh

show: ## Show current state
	@terraform show

graph: ## Generate dependency graph
	@terraform graph | dot -Tpng > graph.png
	@echo "$(GREEN)Graph saved to graph.png$(NC)"
