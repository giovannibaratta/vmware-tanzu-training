locals {
  stage_output = {}

  stage_sensitive_output = {
    for cluster_id, cluster in local.tkgs_clusters : "${cluster_id}-kubeconfig" => yamlencode(module.tkgs_clusters[cluster_id].kubeconfig)
  }
}

resource "local_file" "stage_output" {
  count = var.output_dir != null ? 1 : 0

  content = jsonencode({
    for k, v in local.stage_output : k => v if v != null
  })

  filename = "${var.output_dir}/output.json"
}

resource "local_sensitive_file" "stage_sensitive_output" {
  count = var.sensitive_output_dir != null ? 1 : 0

  content = jsonencode({
    for k, v in local.stage_sensitive_output : k => v if v != null
  })

  filename = "${var.sensitive_output_dir}/sensitive-output.json"
}
