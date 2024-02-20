# Flux

This is an example on how to structure folders to be used in TMC. The path to the directory `tanzu-packages` must be used as root dir for the Kustomization, the file `kustomization.yaml`in the folder will be automatically used an entry point for all the configurations.


## Folder structure

`clusters/base` contains the resources that must be deployed in each cluster
`clusters/overlays` contains the customization that must be applied to specific clusters.

Flux does not support multi-layer overlays (an overlay that references another overlay). For this reason, each cluster can only have a single overlays entry point. This file is represented by `kustomization.yaml`. If we want to have simulate this behavior we can use the `Component`resource. The structure of the overlays folder will look like this:

```
overlays
├── dev # First layer of overlays for group dev
│   ├── dev-safe # Second layer of overlays
│   │   ├── app1-replicas.yaml
│   │   └── kustomization.yaml
│   ├── dev-unsafe # Second layer of overlays
│   │   └── kustomization.yaml
│   └── shared # Contains the overlays of the first layer
│       ├── app1-replicas.yaml
│       └── kustomization.yaml
└── production # First layer of overlays for group production
```

The overlays entrypoint of a cluster must be created in the last layer of the overlays (e.g. dev-safe). Each folder represent a single cluster. This layer will then reference the components of the first layer store in the `shared` folder.

> The shared folder is required otherwise if you try to include the dev directory Flux will complain about a possible cycle.

## Cheatsheet

Preview manifests that will be applied
```bash
kustomize build <path-to-folder-containing-kustomization.yaml>
```

Generate diff with online configuration
```bash
export KUBECTL_EXTERNAL_DIFF="colordiff -N -u"
kustomize build <path-to-folder-containing-kustomization.yaml> | kubectl diff -f -
```