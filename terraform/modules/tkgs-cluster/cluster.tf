locals {
  is_apply_action  = var.desired_state == "PRESENT"
  is_delete_action = var.desired_state == "DELETED"
  context_flag     = var.supervisor_context_name != null ? "--context ${var.supervisor_context_name}" : ""
  manifest = templatefile("${path.module}/files/tkc-cluster.yaml.tpl", {
    cluster_name           = var.cluster_name
    cluster_namespace      = var.cluster_namespace
    vm_class               = var.vm_class
    storage_class          = var.storage_class
    tkr                    = var.tkr
    control_plane_replicas = var.control_plane_replicas
    worker_node_replicas   = var.worker_node_replicas
    additional_ca          = try(base64encode(var.additional_ca), null)
  })
}

# The Kubernetes provider provide a resource kubernetes_manifest to manage CRD but during the plan
# and the apply it needs to list the CRDs and this operation can not be performed in a supervisor
# cluster unless you manually create the necessary role bindings (this means that you have to connect
# with the Kubernetes credentials available in the supervisor nodes).
# This is a workaround to deploy TKC cluster until a proper Terraform provider is implemeted

resource "terraform_data" "apply_cluster" {
  count = local.is_apply_action ? 1 : 0

  triggers_replace = [
    local.manifest
  ]

  provisioner "local-exec" {
    command    = "kubectl apply -f - ${local.context_flag} <<< \"${local.manifest}\""
    on_failure = fail
  }

  provisioner "local-exec" {
    command    = "kubectl wait -f - --for=condition=Ready --timeout=20m ${local.context_flag} <<< \"${local.manifest}\""
    on_failure = fail
  }
}

resource "terraform_data" "delete_cluster" {
  count = local.is_delete_action ? 1 : 0

  provisioner "local-exec" {
    command    = "kubectl delete tkc -n ${var.cluster_namespace} ${var.cluster_name} ${local.context_flag}"
    on_failure = fail
  }

  depends_on = [terraform_data.apply_cluster]
}
