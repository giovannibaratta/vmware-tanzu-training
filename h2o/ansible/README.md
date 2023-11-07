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

### Ansible identity

The Ansible host controller must be registered in Conjur to be able to read secrets. The registration can be done using the same Ansible role or by manually enrolling the host (or via policy) and generating the respective identity files.

```yaml
file: conjur.conf

account: lab
appliance_url: https://<CONJUR_SERVER>
cert_file: <PATH_TO_CONJUR_PEM_FILE>
```

```yaml
file: conjur.identity

machine https://<CONJUR_SERVER>/authn
    login host/automation/ansible
    password <HOST_API_KEY>
```

Secrets can be retrieved in this way

```yaml
ansible.builtin.set_fact:
      keycloak_db_password: "{{ lookup('cyberark.conjur.conjur_variable', 'automation/keycloak/db_pass', config_file='../conjur.conf', identity_file='../conjur.identity') }}"
```

### Force registration of host

If the host was registered to a different Conjur server and you want to force the registration again when the role is executed, you can delete the file `/etc/conjur.identity` in the target host. 


