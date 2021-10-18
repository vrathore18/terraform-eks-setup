resource "null_resource" "setup_kubernetes_metric_server" {
  depends_on = [module.eks]

  triggers = {
    kubernetes_dashboard_manifest = filesha1("kubernetes-manifests/kubernetes-metric-server.yaml")
  }

  provisioner "local-exec" {
    working_dir = path.module

    command = <<EOS
kubectl apply -f kubernetes-manifests/kubernetes-metric-server.yaml --kubeconfig .kube_config.yaml
EOS

  }
}

