resource "random_password" "tmc_admin" {
  length           = 10
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

resource "keycloak_user" "tmc_admin" {
  realm_id = keycloak_realm.tanzu.id
  username = "tmc-admin"
  enabled  = true

  email          = "tmc-admin@${var.domain}"
  email_verified = true

  initial_password {
    value     = random_password.tmc_admin.result
    temporary = false
  }
}

resource "keycloak_user_groups" "tmc_amdin" {
  realm_id = keycloak_realm.tanzu.id
  user_id  = keycloak_user.tmc_admin.id

  group_ids = [
    keycloak_group.tmc_admin.id
  ]
}

resource "random_password" "tmc_member" {
  length           = 10
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

resource "keycloak_user" "tmc_member" {
  realm_id = keycloak_realm.tanzu.id
  username = "tmc-member"
  enabled  = true

  email          = "tmc-member@${var.domain}"
  email_verified = true

  initial_password {
    value     = random_password.tmc_member.result
    temporary = false
  }
}

resource "keycloak_user_groups" "tmc_member" {
  realm_id = keycloak_realm.tanzu.id
  user_id  = keycloak_user.tmc_member.id

  group_ids = [
    keycloak_group.tmc_member.id
  ]
}

resource "random_password" "tap_dev" {
  length           = 10
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

resource "keycloak_user" "tap_dev" {
  realm_id = keycloak_realm.tanzu.id
  username = "tap-dev"
  enabled  = true

  email          = "tap-dev@${var.domain}"
  email_verified = true

  initial_password {
    value     = random_password.tap_dev.result
    temporary = false
  }
}