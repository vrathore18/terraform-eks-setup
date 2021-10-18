module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      format("kubernetes.io/cluster/%s", var.name) = "shared"
    },
    {
      "Terraform" = "true"
    },
  )

  public_subnet_tags = merge(
    {
      "kubernetes.io/role/elb" = "1"
    },
    {
      "type" = "public"
    },
  )

  private_subnet_tags = merge(
    {
      format("kubernetes.io/cluster/%s", var.name) = "shared"
    },
    {
      "kubernetes.io/role/internal-elb" = "1"
    },
    {
      "type" = "private"
    },
  )
}

