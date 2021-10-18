resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  depends_on = [module.eks]
  chart      = "${path.module}/charts/cluster-autoscaler"
  lifecycle {
    ignore_changes = [chart]
  }
  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "image.repository"
    value = "us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler"
  }

  set {
    name  = "image.tag"
    value = "v1.18.1"
  }

  set {
    name  = "podAnnotations.iam\\.amazonaws\\.com\\/role"
    value = aws_iam_role.auto_scaler.arn
  }
}

resource "aws_iam_role" "auto_scaler" {
  name_prefix        = "auto_scaler-"
  assume_role_policy = data.aws_iam_policy_document.auto_scaler_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  role       = aws_iam_role.auto_scaler.name
  policy_arn = aws_iam_policy.worker_autoscaling.arn
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "auto_scaler_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [module.eks.worker_iam_role_arn]
    }
  }
}

