# Jenkins

## Install Jenkins (Helm Chart)

[Repo](https://github.com/jenkinsci/helm-charts)

1. Add the helm repo
    ```sh
    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    ```

1. (optional) Show the customizations
    ```sh
    diff <(helm show values jenkins/jenkins --version 4.2.16) jenkins-4.2.16.values.yaml
    ```

1. Give permissions to use PSP
    ```sh
    kubectl apply -f psp-jenkins.yaml
    ```

1. Create a self-signed issuer for cert-manager or create your own secret to hold TLS cert and private key, in the latter case also adapt the helm values (`controller.ingress.tls`).
    ```sh
    kubectl apply -f selfsigned-issuer.yaml
    ```

1. (optional) If using OIC, add the url `https://<JENKINS_SERVER>/securityRealm/finishLogin` to the valid redirect urls.

1. Install the chart
    ```sh
    helm install -f jenkins-4.2.16.values.yaml jenkins jenkins/jenkins --version 4.2.16
    ```

### Pick a different version

List the available version

```sh
helm search repo jenkins/jenkins --versions
```

Get default values

```sh
helm show values jenkins/jenkins --version <VERSION>
```
