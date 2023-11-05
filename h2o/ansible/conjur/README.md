# Conjur

## Setup

Install the required roles in the ansible controller.
```sh
ansible-galaxy role install geerlingguy.docker
```

Create in this directory a file named `secrets.yaml`. Set the database password that will be used in the docker compose file generate by Ansible.

```yaml
file: secrets.yaml

---
postgres_password: <REPLACE_ME>
``````

Run the ansible playbook to configure the remote host. This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

```sh
ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian --extra-vars "@secrets.yaml"
```


## Limitations
open source version does not have an UI