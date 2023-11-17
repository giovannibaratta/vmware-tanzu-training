# Jenkins

This folder contains the resource to deploy a Jenkins server in Kubernetes with the following features:
* Authentication is provided via OIDC
* Authorization is provided using RBAC based on groups provided by the OIDC provider
* An example of view/edit role to access a specific folder

Prerequisites:
* ingress controller to expose the server
* cert-manager to generated a self-signed certificate for the server

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
    kubectl apply -f selfsigned-issuer.yaml -n jenkins
    ```

1. (optional) If using OIC, add the url `https://<JENKINS_SERVER>/securityRealm/finishLogin` to the valid redirect urls.

1. Install the chart
    ```sh
    export OIDC_CLIENT_SECRET=$(cat ../ansible/keycloak/outputs/jenkins_secret)
    envsubst < jenkins-4.2.16.values.yaml | helm install -f - jenkins jenkins/jenkins --version 4.2.16 -n jenkins
    OIDC_CLIENT_SECRET=
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

## Configuration

##### Groups

Groups must be defined and assigned to user by the OIDC provider. To verify that the user has the correct groups go to the WhoAmI (`https://<SERVER_URL>/whoAmI/`) page in Jenkins. The assigned groups are listed in the "Authorities" section.

##### JCasC

The configuration of the server is managed via configScript defined in the values file. The list of supported configurations is available at `https://<SERVER_URL>/manage/configuration-as-code/reference`. After changing the values file, use Helm to deploy the new configurations.

    ```sh
    export OIDC_CLIENT_SECRET=$(cat ../ansible/keycloak/outputs/jenkins_secret)
    envsubst < jenkins-4.2.16.values.yaml | helm upgrade -f - jenkins jenkins/jenkins --version 4.2.16 -n jenkins
    OIDC_CLIENT_SECRET=
    ```