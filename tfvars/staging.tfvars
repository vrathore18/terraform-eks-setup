name = "staging"
target_account_id = "916148231619"
aws_user = "vikas" // role you want to add in aws_auth
region = "eu-west-2"
vpc_cidr = "11.2.0.0/24"
azs = ["eu-west-2a","eu-west-2b","eu-west-2c"]
public_subnets = ["11.2.0.0/26","11.2.0.128/26"]
private_subnets = ["11.2.0.192/26","11.2.0.64/26"]
eks_instance_type = "t3.xlarge"
cluster_version = "1.21"

