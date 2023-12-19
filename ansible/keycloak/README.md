# Keycloak

## Prerequisites
* Ansible inventory with a group named "keycloak" is defined
* TLS certificate and private key for Keycloak.

## Install Keycloak

1. Define a variable file with the following variables:
   * artifacts_dir (directory containing `tls/certificate`, `tls/issuer.pem`, `tls/private-key.pem`)
   * keycloak_db_password
   * keycloak_admin_password

1. Run ansible to install Keycloak
   ```sh
   ansible-playbook setup.yaml \
      -i ../../terraform/outputs/01-tkgm-vsphere-nsx/ansible_inventory \
      --u debian \
      --extra-vars "@inputs/h2o-2-21094/installation.yaml"
   ```

1. Verify that Keycloak portal is up and running (connect to `https://<VM_IP>`).

1. Set the variables in the playbook `configure.yaml`

1. Run ansible to configure Keycloak realm

   ```sh
   ansible-playbook configure.yaml -i ../../terraform/unstaged/outputs/ansible_inventory --u debian
   ```

1. The client secret of the newly created user can be retrieved from UI

## Groups and roles

The groups used by external applications are named roles in Keycloak. With a role you defined a capability of the user that the external application will check before granting permissions to the user. The group instead is a way to group users and assign roles.

A Keycloak group contains users and can contain multiple roles.
A role is just a name that represent a capability.

To expose the roles of the user in the token we have to:

1. create an additional scope
1. Assign the built-in mapper groups that will add the roles of the user to the property groups in the token (the property name can be changed)
1. We assign the scope to the OIDC client.
