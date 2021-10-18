provider "aws" {
  region  = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.target_account_id}:role/terraform"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

terraform {
   backend "s3" {}
}

data "terraform_remote_state" "state" {
  backend = "s3"

  config = {
    bucket         = var.backend_config_bucket
    region         = var.backend_config_bucket_region
    key            = "${var.name}/${var.backend_config_tfstate_file_key}" # var.name == CLIENT
    role_arn       = var.backend_config_role_arn
  }
}