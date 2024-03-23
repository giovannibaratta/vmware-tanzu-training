locals {
  stage_output = {}

  stage_sensitive_output = {
    "tmc_oidc_provider" = try({
      issuer_url    = "${var.idp_provider.url}/realms/${keycloak_realm.tanzu.realm}"
      client_id     = keycloak_openid_client.tmc.client_id
      client_secret = keycloak_openid_client.tmc.client_secret
    }, null),
    "tmc_admin_user" = try({
      username = keycloak_user.tmc_admin.username
      password = keycloak_user.tmc_admin.initial_password.0.value
    }, null),
    "tmc_member_user" = try({
      username = keycloak_user.tmc_member.username
      password = keycloak_user.tmc_member.initial_password.0.value
    }, null),
    "tap_dev_user" = try({
      username = keycloak_user.tap_dev.username
      password = keycloak_user.tap_dev.initial_password.0.value
    }, null),
    "tap_oidc_provider" = try({
      issuer_url    = "${var.idp_provider.url}/realms/${keycloak_realm.tanzu.realm}"
      client_id     = keycloak_openid_client.tap.client_id
      client_secret = keycloak_openid_client.tap.client_secret
    }, null),
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
