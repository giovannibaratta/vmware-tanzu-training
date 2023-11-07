## Integrate Ansible with Conjur

Install the Conjur collection to be able to use the lookup plugin and the necessary roles in the Ansible host.

```sh
ansible-galaxy collection install cyberark.conjur
```

Each host that needs to access Conjur secerts must have the following block in the Ansible playbook.

```
- role: cyberark.conjur.conjur_host_identity
  conjur_appliance_url: 'https://conjur.myorg.com'
  conjur_account: 'myorg'
  conjur_host_factory_token: "{{ lookup('env', 'HFTOKEN') }}"
  conjur_host_name: "{{ inventory_hostname }}"
  conjur_ssl_certificate: "{{ lookup('file', '/path/to/conjur.pem') }}"
  conjur_validate_certs: yes
```

> HFTOKEN is a token that must be set in the Ansible host as an environment variable. The token can be created using `conjur hostfactory tokens create --hostfactory-id <HOST_FACTORY_NAME> --duration-hours 2`




