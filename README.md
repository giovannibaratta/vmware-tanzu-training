# About this repo

This repository is a collection of code and artifacts used while learning and experimenting with VMware products. Things will evolve and content will be re-organized based on what I am currently working on.
The chance that what you find here will work "as it is" is zero, nevertheless it could be useful as a starting point. Also there are several cross-reference inside the repo, they might be broken or not working as intended when starting from scratch.

## Folder structure

<!-- BEGIN_FOLDER_STRUCTURE -->
```sh
.
├── ansible # Contains Ansible playbooks to setup and configure applications
├── apps # Contains example applications
├── debian-golden-image # Contains Packer code to deploy a debian golden image
├── docs
├── falco # Contains manifests to deploy Falco in Kubernetes
├── home-lab # Ignore this folder
├── jenkins # Contains the instructions and manifests to deploy Jenkins in Kubernetes
├── manifests # Contains various manifests to install applications in Kubernetes
├── scripts # Contains various scripts
└── terraform # Contains Terraform code to deploy various components in vSphere, Vault and Kuber...
```
<!-- END_FOLDER_STRUCTURE -->

## Encrypted configuration files

Configuration files that contain also sensitive data (e.g. token, password, ...) have been encrypted using [sops](https://github.com/getsops/sops). In order to decrypt the file you need the private key used for the encryption or you need to provide new values for those secrets (based on your environment). If you want to update and commit the sensitive values you have to decrypt and crypt again the file. These type of files can be recognized by the string `.sops` included in the filename and they have additional metadata inside the file.

Encrypt the file
```sh
sops --encrypt --in-place --mac-only-encrypted --encrypted-regex '^(<regexToMatchProperties>)$' <file-path>
```

Decrypt the file
```
sops --decrypt --in-place --encrypted-regex '^(<regexToMatchProperties>)$' <file-path>
```

> The regex used to encrypt a file can be found inside the encrypted file