env=$1
process=$2

if [ "${env}" == "staging" ]; then
    BACKEND_CONFIG_BUCKET_REGION="eu-west-2"
    BACKEND_CONFIG_BUCKET="fiter-terraform-tfstate-files"
    BACKEND_CONFIG_TFSTATE_FILE_KEY="terraform.tfstate"
    BACKEND_CONFIG_ROLE_ARN="arn:aws:iam::916148231619:role/terraform"
fi

if [ "${process}" == "init" ] && [ "${env}" == "staging" ]; then
    terraform init  \
        -backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
        -backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
        -backend-config "key=${env}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
        -backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

elif [ "${process}" == "plan" ] && [ "${env}" == "staging" ]; then
    terraform init -reconfigure \
        -backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
        -backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
        -backend-config "key=${env}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
        -backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"
        
    terraform plan -no-color \
        -var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
        -var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
        -var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
        -var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
        -var name=${env} \
        -var-file=tfvars/${env}.tfvars \
        -out=terraform.plan

elif [ "${process}" == "apply" ] && [ "${env}" == "staging" ]; then
    terraform init -reconfigure \
        -backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
        -backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
        -backend-config "key=${env}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
        -backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

    terraform apply  -auto-approve \
        -var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
        -var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
        -var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
        -var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
        -var name=${env} \
        -var-file=tfvars/${env}.tfvars
fi