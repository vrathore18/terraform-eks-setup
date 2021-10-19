resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  depends_on = [module.eks]

  namespace = "kube-system"
  chart     = "${path.module}/charts/metrics-server"
  lifecycle {
    ignore_changes = [chart]
  }

  recreate_pods = "true"
}