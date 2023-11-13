# Deploy Kubernetes dashboard

1. Apply default manifests
    `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml`
1. Add patch for PSP
    `ytt -f references/rbac-psp-rolebinding/data-schema.yaml -f references/rbac-psp-rolebinding/rbac-psp-rolebinding.yaml -f kubernetes-dashboard/psp-patch.yaml | kubectl apply -f -`