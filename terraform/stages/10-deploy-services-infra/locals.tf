locals {
  deploy_jumpbox = var.services.bastion == true
  deploy_harbor = var.services.registry == true
  depoy_keylock = var.services.idp == true
  deploy_minio = var.services.s3 == true
}
