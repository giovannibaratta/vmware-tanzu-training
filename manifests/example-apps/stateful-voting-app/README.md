# Stateful app

This folder contains the resources to deploy and example of a stateful application on Kubernetes. The application has been copied from [example-voting-app](https://github.com/dockersamples/example-voting-app/tree/main).

The app has been adapted using Kustomize to be able to run on a TKG cluster.

## Deploy the app

export TARGET_NS=voting-app
envsubst < namespace.yaml | kubectl apply -f -
kubectl apply -k . -n "${TARGET_NS}"

## Fetch upstream updates

1. Run `./clone-upstream-repo.sh`
1. Manually remove non-existing resources or run `kustomize edit remove resource voting-app/*.yaml`
1. Manually add new resources or run `kustomize edit add resource voting-app/*.yaml`