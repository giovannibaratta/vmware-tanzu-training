# Keycloak

This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

1. Setup Ansible identity. See parent [README](../README.md#ansible-identity) for more details.

1. Run ansible

    ```sh
    ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian
    ```
