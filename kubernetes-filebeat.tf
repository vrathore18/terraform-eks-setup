# # add filebeat integration
# data "template_file" "filebeat_kubernetes" {
#   template = file("kubernetes-manifests/filebeat-kubernetes.yaml.tpl")

#   vars = {
#     aws_account_id         = data.aws_caller_identity.current.account_id
#     elasticsearch_host     = var.elasticsearch_host
#     elasticsearch_username = var.elasticsearch_username
#     elasticsearch_password = var.elasticsearch_password
#   }
# }

# resource "local_file" "filebeat_kubernetes" {
#   content  = data.template_file.filebeat_kubernetes.rendered
#   filename = ".filebeat-kubernetes.yaml"
# }

# resource "null_resource" "setup_filebeat" {
#   depends_on = [
#     module.eks,
#     local_file.filebeat_kubernetes,
#   ]

#   triggers = {
#     filebeat_kubernetes = data.template_file.filebeat_kubernetes.rendered
#   }

#   provisioner "local-exec" {
#     working_dir = path.module

#     command = <<EOS
# kubectl apply -f .filebeat-kubernetes.yaml --kubeconfig .kube_config.yaml
# EOS

#   }
# }

# resource "null_resource" "filebeat_cleanup" {
#   depends_on = [null_resource.setup_filebeat]

#   provisioner "local-exec" {
#     working_dir = path.module

#     command = <<EOS
# rm -f .filebeat-kubernetes.yaml
# EOS

#   }
# }

