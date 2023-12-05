locals {
  avi = merge(var.avi, var.avi_sensitive)
}