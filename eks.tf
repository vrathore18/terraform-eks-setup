module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "17.0.0"
  cluster_name                                 = var.name
  subnets                                      = module.vpc.private_subnets
  vpc_id                                       = module.vpc.vpc_id
  cluster_version                              = var.cluster_version
  worker_ami_name_filter                       = "amazon-eks-node-1.18-v20201126"
  kubeconfig_aws_authenticator_additional_args = ["-r", "arn:aws:iam::${var.target_account_id}:role/terraform"]

  worker_groups = [
    {
      instance_type        = var.eks_instance_type
      asg_desired_capacity = var.eks_asg_desired_capacity
      asg_max_size         = var.eks_asg_max_size
      key_name             = var.key_name
      autoscaling_enabled  = true
      root_volume_type     = "gp2"
      subnets              = module.vpc.private_subnets
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
      ]
    },
  ]
  map_accounts = [var.target_account_id]
  map_users = [
      {
        userarn = format("arn:aws:iam::%s:user/%s", var.target_account_id, var.aws_user)
        username = "AWS_USERNAME"
        groups = ["system:masters"]
      }
  ]
  map_roles = [
    {
      rolearn = format("arn:aws:iam::%s:role/terraform", var.target_account_id)
      username = format("%s-admin", var.name)
      groups    = ["system:masters"]
    }
  ]

  enable_irsa = true
  write_kubeconfig = false
  # manage_aws_auth=false
}

resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = ".kube_config.yaml"
}