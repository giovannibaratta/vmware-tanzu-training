# The Kubernetes provider provide a resource kubernetes_manifest to manage CRD but during the plan
# and the apply it needs to list the CRDs and this operation can not be performed in a supervisor
# cluster unless you manually create the necessary role bindings (this means that you have to connect
# with the Kubernetes credentials available in the supervisor nodes).
# This is a workaround to deploy TKC cluster until a proper Terraform provider is implemeted

resource "terraform_data" "tmc_cluster" {

  input = {
    manifest = "${path.module}/files/tmc-cluster.yaml"
    context  = var.supervisor_context_name
  }

  provisioner "local-exec" {
    command    = "kubectl apply -f ${self.input.manifest} --context ${self.input.context}"
    on_failure = fail
  }

  provisioner "local-exec" {
    command    = "kubectl wait -f ${self.input.manifest} --for=condition=Ready --timeout=20m --context ${self.input.context}"
    on_failure = fail
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ${self.input.manifest} --context ${self.input.context}"
  }
}

locals {
  tmc_cluster_manifest = yamldecode(file("${path.module}/files/tmc-cluster.yaml"))
}

data "kubernetes_secret_v1" "tmc_cluster_admin_kubeconfig" {
  metadata {
    name      = "${local.tmc_cluster_manifest.metadata.name}-kubeconfig"
    namespace = local.tmc_cluster_manifest.metadata.namespace
  }

  depends_on = [terraform_data.tmc_cluster]
}

locals {
  tmc_cluster_admin_kubeconfig = yamldecode(data.kubernetes_secret_v1.tmc_cluster_admin_kubeconfig.data.value)
}

resource "local_sensitive_file" "tmc_kubeconfig" {
  content  = data.kubernetes_secret_v1.tmc_cluster_admin_kubeconfig.data.value
  filename = "${var.sensitive_output_dir}/kubeconfigs/tmc-admin-kubeconfig"
}

