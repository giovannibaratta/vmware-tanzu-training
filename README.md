# About this repo

This repository is used to collect code and artifacts used while learning and experimenting with VMware products. Things will evolve and content will be re-organized based on what I am currently working on.
The chance that what you find here will work "as it is" is zero, nevertheless it could be useful as a starting point. Also there are several cross-reference inside the repo, they might be broken or not working as intended when starting from scratch.

## Folder structure

<!-- BEGIN_FOLDER_STRUCTURE -->```sh

.
├── ansible # Contains Ansible playbooks to setup and configure applications
├── apps # Contains example applications
├── falco # Contains manifests to deploy Falco in Kubernetes
├── home-lab # Ignore this folder
├── jenkins # Contains the instructions and manifests to deploy Jenkins in Kubernetes
├── manifests # Contains various manifests to install applications in Kubernetes
├── packer # Contains Packer code to deploy a debian golden image
├── scripts # Contains various scripts
├── terraform # Contains Terraform code to deploy various components in vSphere, Vault and Kuber...
├── tmc-self-managed # Ignore this folder
└── velero # Contains instructions to install Velero
```
<!-- END_FOLDER_STRUCTURE -->