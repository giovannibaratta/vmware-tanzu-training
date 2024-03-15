resource "harbor_project" "projects" {
  for_each = var.registry_projects

  name                   = each.value
  public                 = true
  vulnerability_scanning = false
}