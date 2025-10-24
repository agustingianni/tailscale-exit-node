# ------------------------------------------------------------------------------
# Terraform Makefile
#
# This Makefile provides convenient commands for managing Terraform workflows.
# It simplifies running common Terraform operations such as init, plan, apply,
# and destroy — ensuring consistent usage and repeatable infrastructure workflows.
#
# Usage:
#   make <target>
#
# Examples:
#   make init          # Initialize Terraform backend and providers
#   make plan          # Generate an execution plan
#   make apply         # Apply changes
#   make destroy       # Tear down infrastructure
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# Default shell for executing commands
SHELL := /bin/bash

# Directory containing Terraform configuration files
TF_DIR ?= .

# Path to the Terraform variable definitions file
TF_VARS ?= terraform.tfvars

# Path to save the Terraform plan file (used for apply-plan)
TF_PLAN ?= plan.tfplan

# ------------------------------------------------------------------------------
# Phony targets (not associated with actual files)
# ------------------------------------------------------------------------------

.PHONY: init fmt fmt-check validate plan plan-save apply apply-plan destroy output clean

# ------------------------------------------------------------------------------
# Terraform Commands
# ------------------------------------------------------------------------------

## Initialize providers and backends
## This command sets up the Terraform working directory by downloading providers
## and initializing backend state configuration.
init:
	terraform -chdir=$(TF_DIR) init

## Format configuration files
## Automatically reformats Terraform files (.tf) to follow canonical style.
fmt:
	terraform -chdir=$(TF_DIR) fmt

## Check formatting without modifying files
## Fails if any Terraform files are not properly formatted.
fmt-check:
	terraform -chdir=$(TF_DIR) fmt -check

## Validate syntax and internal consistency
## Ensures all Terraform configurations are syntactically valid and consistent.
validate:
	terraform -chdir=$(TF_DIR) validate

## Generate and display an execution plan
## Runs terraform plan to show what actions Terraform will take.
## This depends on fmt-check and validate for correctness.
plan: fmt-check validate
	terraform -chdir=$(TF_DIR) plan -var-file=$(TF_VARS)

## Generate and save an execution plan to a file
## Saves the generated plan to $(TF_PLAN), which can later be applied safely.
plan-save: fmt-check validate
	terraform -chdir=$(TF_DIR) plan -var-file=$(TF_VARS) -out=$(TF_PLAN)

## Apply changes (using a fresh plan)
## Executes terraform apply directly from configuration and variables.
apply: plan
	terraform -chdir=$(TF_DIR) apply -var-file=$(TF_VARS)

## Apply a previously saved plan
## Safer option for applying an already-reviewed Terraform plan.
apply-plan:
	terraform -chdir=$(TF_DIR) apply $(TF_PLAN)

## Destroy infrastructure
## Tears down all managed infrastructure described by the configuration.
destroy:
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TF_VARS)

## Show outputs
## Displays Terraform outputs after an apply.
output:
	terraform -chdir=$(TF_DIR) output

## Clean up generated files
## Removes temporary plan files to keep the working directory clean.
clean:
	rm -f $(TF_PLAN)
