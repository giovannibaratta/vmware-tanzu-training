# Terraform

The folder contains Terraform resources to deploy and build various types of environment.

The folder `stages` is the entrypoint and contains the resources that must be applied. There are several stages for different kind of environments.
The folder `modules`contains reusable piece of code that are used across different stages.

## Apply

While stages can be applied using the standard Terraform script, a script is provided to ease the process. `tf-helper.sh` accepts two arguments, an action (plan or apply) and the name of the stage on which the action must be performed.

```sh
./tf-helper plan 00-bootstrap
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->

<!-- END_TF_DOCS -->