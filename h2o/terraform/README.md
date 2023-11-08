1. Define the necessary variables (see [here](./variables.tf) for a complete list)
1. Apply Terraform
    ```sh
    terraform apply -var-file=terraform.tfvars -var-file=terraform-secrets.tfvars
    ```