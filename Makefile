.PHONY: init-stg plan-stg apply-stg destroy-stg check-stg

move-stg:
	cd stg
init-stg:
	make move-stg
	make check
	terraform init
plan-stg:
	make move-stg
	make check
	terraform plan
apply-stg:
	make move-stg
	make check
	terraform apply
destroy-stg:
	make move-stg
	make check
	terraform destroy
check-stg:
	make move-stg
	terraform fmt -recursive
	terraform fmt -check
	terraform validate
