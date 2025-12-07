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

TF_VAR_FILE ?= terraform.tfvars
SSH_WINDOW_MINUTES ?= 15

.PHONY: ssh-enable ssh-disable ssh-temporary

# Detect public IP using a reliable AWS HTTP endpoint
PUBLIC_IP := $(shell curl -s https://checkip.amazonaws.com)

ssh-enable:
	@echo ">>> Enabling SSH for Swarm manager"
	@echo ">>> Detected IP: $(PUBLIC_IP)"
	@printf "enable_ssh_to_manager = true\nssh_cidr_manager = \"%s/32\"\n" "$(PUBLIC_IP)" > $(TF_VAR_FILE)
	terraform apply -var-file=$(TF_VAR_FILE)

ssh-disable:
	@echo ">>> Disabling SSH (port 22) for Swarm manager"
	@echo 'enable_ssh_to_manager = false' > $(TF_VAR_FILE)
	terraform apply -var-file=$(TF_VAR_FILE)

ssh-temporary:
	@echo ">>> Opening SSH for $(SSH_WINDOW_MINUTES) minutes"
	$(MAKE) ssh-open
	@echo ">>> SSH is now enabled for your IP ($(PUBLIC_IP))"
	@echo ">>> Will disable in $(SSH_WINDOW_MINUTES) minutes..."
	sleep $$(echo "$(SSH_WINDOW_MINUTES) * 60" | bc)
	$(MAKE) ssh-close
	@echo ">>> SSH window closed"
