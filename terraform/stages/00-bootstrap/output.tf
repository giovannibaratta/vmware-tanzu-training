locals {
  stage_output = {
    "ca_certificate" = tls_self_signed_cert.ca.cert_pem,
  }

  stage_sensitive_output = {
    "ca_private_key" = tls_private_key.ca.private_key_pem,
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