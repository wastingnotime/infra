# infra/Makefile

# List of Terraform components (each is a directory with its own .tf files)
COMPONENTS ?= iam ecr swarm

# Terraform binary (override if needed: `make apply TF=tofu`)
TF ?= terraform

.PHONY: help init plan apply init-% plan-% apply-%

help:
	@echo "Usage:"
	@echo "  make init          # terraform init in all components ($(COMPONENTS))"
	@echo "  make plan          # terraform plan in all components"
	@echo "  make apply         # terraform apply in all components"
	@echo ""
	@echo "Per-component:"
	@echo "  make init-iam      # terraform init in infra/iam"
	@echo "  make plan-ecr      # terraform plan in infra/ecr"
	@echo "  make apply-swarm   # terraform apply in infra/swarm"
	@echo ""
	@echo "Override components:"
	@echo "  make apply COMPONENTS=\"iam ecr\""

init:
	@for dir in $(COMPONENTS); do \
		echo "==> terraform init in $$dir"; \
		( cd $$dir && $(TF) init ); \
	done

plan:
	@for dir in $(COMPONENTS); do \
		echo "==> terraform plan in $$dir"; \
		( cd $$dir && $(TF) plan ); \
	done

apply:
	@for dir in $(COMPONENTS); do \
		echo "==> terraform apply in $$dir"; \
		( cd $$dir && $(TF) apply ); \
	done

# Per-component targets, e.g. `make plan-iam`
init-%:
	@echo "==> terraform init in $*"
	@cd $* && $(TF) init

plan-%:
	@echo "==> terraform plan in $*"
	@cd $* && $(TF) plan

apply-%:
	@echo "==> terraform apply in $*"
	@cd $* && $(TF) apply
