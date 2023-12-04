# Vault

This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

1. Run ansible to install Vault

    ```sh
    ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian
    ```
1. Customize the variables `vars/initialize_vault.yaml` if needed
1. Initialize Vault cluster
    ```sh
    ansible-playbook initialize.yaml -i ../../terraform/outputs/ansible_inventory --u debian --extra-vars "@secrets.yaml"
    ```