resource "random_id" "node_id" {
  count       = var.num_nodes
  byte_length = 4
}

locals {
  # node_specs must have keys that are know during the apply otherwise Terraform will complain
  node_specs = { for node_index in range(var.num_nodes) : tostring(node_index) => {
      id = random_id.node_id[node_index].hex
    }
  }
}
