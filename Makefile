.PHONY: init-stg plan-stg apply-stg destroy-stg check-stg
ARG = hoge

init-stg:
	make check-stg
	cd ./stg && terraform init -backend-config="./stg.tfbackend" -backend-config="${ARG}"
plan-stg:
	make check-stg
	cd ./stg && terraform plan -var-file="config.tfvars"
apply-stg:
	make check-stg
	cd ./stg && terraform apply
destroy-stg:
	make check-stg
	cd ./stg && terraform destroy -var-file="config.tfvars"
check-stg:
	cd ./stg && terraform fmt -recursive
	cd ./stg && terraform fmt -check
	cd ./stg && terraform validate -var-file="config.tfvars"
