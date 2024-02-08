# Gitlab

1. Create Gitlab namespace
    ```bash
    kubectl create ns gitlab
    ```

1. Add label if Pod security admission controller is enabled
    ```bash
    kubectl label ns gitlab pod-security.kubernetes.io/enforce=privileged
    ```

1. Create self signed CA
    ```bash
    kubectl create -f gitlab-issuer.yaml
    ```

1. Install Gitlab
    ```bash
    helm upgrade --install gitlab gitlab/gitlab --timeout 600s -n gitlab -f gitlab-values.yaml
    ```
