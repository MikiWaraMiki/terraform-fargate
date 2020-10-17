.PHONY: init-stg plan-stg apply-stg destroy-stg check-stg

move-stg:
	cd stg
init-stg:
	make move-stg
	make check-stg
	terraform init
plan-stg:
	make move-stg
	make check-stg
	terraform plan -var-file="config.tfvars"
apply-stg:
	make move-stg
	make check-stg
	terraform apply
destroy-stg:
	make move-stg
	make check-stg
	terraform destroy -var-file="config.tfvars"
check-stg:
	make move-stg
	terraform fmt -recursive
	terraform fmt -check
	terraform validate -var-file="config.tfvars"
