# Kratos

This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

```sh
ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian
```