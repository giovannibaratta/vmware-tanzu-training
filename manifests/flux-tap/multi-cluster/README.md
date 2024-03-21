## Install TAP plugins for Tanzu CLI

```sh
tanzu plugin install --group vmware-tap/default:v1.8
```

## Build a workload

In the build cluster

```sh
tanzu apps workload create demo-app \
--git-repo https://github.com/giovannibaratta/tap-test-app \
--label app.kubernetes.io/part-of=tanzu-java-web-app
--git-branch main \
--type web \
--yes \
--namespace app-1
```

## Deploy the workload

Retrieve the deliverable from the build cluster

```sh
kubectl get configmap demo-app -n app-1 -o go-template='{{.data.deliverable}}' > deliverable.yaml
```

Apply the deliverable in the run cluster

```sh
kubectl apply -f deliverable.yaml -n app-1
```