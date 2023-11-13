# MinIO

This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

1. Setup Ansible identity. See parent [README](../README.md#ansible-identity) for more details.

1. Populate the variables `automation/minio/root_password` and `automation/minio_backup_user_secretkey` in Conjur

1. Run ansible to install MinIO

    ```sh
    ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian
    ```

1. Verify that MinIO portal is up and running (connect to `https://<VM_IP>`).

1. Run ansible to configure MinIO user and bucket
    ```sh
    ansible-playbook configure.yaml -i ../../terraform/outputs/ansible_inventory --u debian
    ```