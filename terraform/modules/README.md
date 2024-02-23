# Terraform modules

The modules that contains a `version` file in the root directory of the module will be automatically versioned using a Git tag. A GitHub action is configured to scan the modules and generate a new tag every time the version specified in the file is modified.

The modules can be referenced using the following syntax:

```hcl
module "my-module" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/<MODULE-NAME>?ref=<MODULE-NAME>-v<MODULE-VERSION>&depth=1"

  ...
}
```