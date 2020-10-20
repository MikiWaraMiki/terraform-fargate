.PHONY: init-stg plan-stg apply-stg destroy-stg check-stg
ARG = hoge

init-stg:
	make check-stg
	terraform init -backend-config="./stg.tfbackend" -backend-config="${ARG}"
plan-stg:
	make check-stg
	terraform plan -var-file="../config.tfvars"
apply-stg:
	make check-stg
	terraform apply -var-file="../config.tfvars"
destroy-stg:
	make check-stg
	terraform destroy -var-file="../config.tfvars"
check-stg:
	terraform fmt -recursive
	terraform fmt -check
	terraform validate -var-file="../config.tfvars"
