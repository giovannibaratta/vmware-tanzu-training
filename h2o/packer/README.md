# Golden image

This folder contains the resources to build a golden image (empty for now) on vSphere using Packer.

At the moment the OVF can not be customized due to some limitations of the provider.

## How to build

1. Install plugins
    `packer init .`
1. Create a variable file and add all the required variables to connect to the vCenter
1. Build the image
    `packer build -var-file=variables.pkrvars.hcl .`
1. The previous step will generate a template in the specified folder. To export the template you have to clone it in content library (right click -> <i>Clone to library</i>). Once is in the library, you can use or export it.