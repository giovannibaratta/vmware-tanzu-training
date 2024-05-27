# Terraform

The folder contains Terraform resources to deploy and build various types of environment.

The folder `stages` is the entrypoint and contains the resources that must be applied. There are several stages for different kind of environments.
The folder `modules`contains reusable piece of code that are used across different stages.

## Apply

While stages can be applied using the standard Terraform script, a script is provided to ease the process. `tf-helper.sh` accepts two arguments, an action (plan or apply) and the name of the stage on which the action must be performed.

```sh
./tf-helper plan 00-bootstrap
```

## Manage multiple environments

An helper script is provided to manage multiple environments. The script `tf-state-helper.sh` move the existing state file to a new location and create a new state file for the new environment.

```sh
export GITLAB_TOKEN_NAME=<MY_TOKEN_NAME>
export GITLAB_TOKEN=<MY_TOKEN>

# ./tf-state-helper.sh <STAGE_NAME> <ENV_NAME> <GITLAB_URL_WITH_PROJECT>
./tf-state-helper.sh 00-bootstrap home-lab https://gitlab.com/api/v4/projects/123456
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->

<!-- END_TF_DOCS -->
