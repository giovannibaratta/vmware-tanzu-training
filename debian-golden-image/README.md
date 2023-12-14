# Golden image

This folder contains the resources to build a golden image (empty for now) on vSphere using Packer.

At the moment, the generated OVF can not be customized during deployments due to some limitations of the provider.

## How to build

1. Install plugins
    `packer init .`
1. Create a variable file (e.g. `myvars.pkrvars.hcl` and add all the required variables to connect to the vCenter ([list of supported variables](variables.pkr.hcl)).
1. Build the image
    `packer build -var-file=myvars.pkrvars.hcl .`
1. The previous step will generate a template in the specified folder in vSphere. To export the template you have to clone it in content library (right click -> <i>Clone to library</i>). Once is in the library, you can use or export it.

### Change SSH authorized key

Change the key in `ansible_playbooks/files/authorized_key`.