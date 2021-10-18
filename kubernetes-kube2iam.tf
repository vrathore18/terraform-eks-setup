resource "helm_release" "kube2iam" {
  name       = "kube2iam"
  depends_on = [module.eks]

  namespace = "kube-system"
  chart     = "${path.module}/charts/kube2iam"
  lifecycle {
    ignore_changes = [chart]
  }

  recreate_pods = "true"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "host.iptables"
    value = "true"
  }

  set {
    name  = "host.interface"
    value = "eni+"
  }

  # set default role to avoid pods having access to EKS worker Instance Role
  set {
    name = "extraArgs.base-role-arn"
    value = format(
      "arn:aws:iam::%s:role/",
      data.aws_caller_identity.current.account_id,
    )
  }

  set {
    name  = "extraArgs.default-role"
    value = aws_iam_role.kube2iam_default.name
  }
}

# allow EKS workers assume all roles with names beginning with k8s-app-*
resource "aws_iam_policy" "eks_worker_assume_roles" {
  name_prefix = "eks_worker_assume_roles"
  policy      = data.aws_iam_policy_document.assume_roles.json
}

resource "aws_iam_role_policy_attachment" "assume_roles" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.eks_worker_assume_roles.arn
}

data "aws_iam_policy_document" "assume_roles" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/k8s-app-*",
    ]
  }
}

# create default role which all pods will be assigned
data "aws_iam_policy_document" "kube2iam_default" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [module.eks.worker_iam_role_arn]
    }
  }
}

resource "aws_iam_role" "kube2iam_default" {
  name_prefix        = "kube2iam_default_"
  assume_role_policy = data.aws_iam_policy_document.kube2iam_default.json
}

