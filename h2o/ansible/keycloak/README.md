# Keycloak

This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

1. Setup Ansible identity. See parent [README](../README.md#ansible-identity) for more details.

1. If if is the first time that you run the playbook, the host will be registered to Conjur. To perform this operation a token is required. The token must be set as an environment variable (HFTOKEN), to generate the token see [here](../README.md#integrate-ansible-with-conjur).

1. Run ansible to install Keycloak

    ```sh
    ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian
    ```

1. Verify that Keycloak portal is up and running (connect to `https://<VM_IP>`).

1. Run ansible to configure Keycloak realm
    ```sh
    ansible-playbook configure.yaml -i ../../terraform/outputs/ansible_inventory --u debian
    ```

1. The client secret of the newly created user can be retrieved from UI