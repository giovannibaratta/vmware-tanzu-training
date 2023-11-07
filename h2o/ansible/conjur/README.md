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
```

Run the ansible playbook to configure the remote host. This README assume that a debian VM has been provisioned with Terraform using the code in this repository. If this is not the case, adjust the parameters of the following command as needed.

```sh
ansible-playbook setup.yaml -i ../../terraform/outputs/ansible_inventory --u debian --extra-vars "@secrets.yaml"
```

## Connect to Conjur

1. install Conjur CLI.
1. `conjur init --url https://<CONJUR_IP_ADDR> --account lab --self-signed`
1. `conjur login -i admin`, it will prompt for a password. Use the API key stored in the VM in `/conjur/config/admin`

## Limitations
open source version does not have an UI

## Findings

* If you receive the error `Missing required option account` when loading a policy, it might mean that there is a duplicate resource (ex. host, host-factory, variable) in policy.