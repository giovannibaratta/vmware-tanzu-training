# TBS standalone on TKGs vSphere 8u2

TKG version installed in v8u2: 2.2

TAP K8s supported version: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/k8s-matrix.html
Interoperability matrix: https://interopmatrix.vmware.com/Interoperability?col=885,&row=551,&isHidePatch=true&isHideGenSupported=true&isHideTechSupported=true&isHideCompatible=false&isHideNTCompatible=false&isHideIncompatible=true&isHideNotSupported=true&isCollection=false

TBS Doc: https://docs.vmware.com/en/Tanzu-Build-Service/1.12/vmware-tanzu-build-service/installing-tap-profile.html
TAP Doc: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/tanzu-build-service-install-tbs.html

> N.B Auto-update feature is deprecated

Install:

1. Install tooling (CLI, ...)
1. Create Harbor project for hosting relocated images
1. Relocate images from Tanzu registry


    * imgpkg tag list is super slow
    * INSTALL_REGISTRY_HOSTNAME should only contain the domain
    * INSTALL_REPO in the Harbor registry must be manually created. Inside the project a repository called `tap-packages` (can be changed) will be created during the copy
    * size of relocated packages 7.82 GiB (lite)

1. Configure Kapp controller to trust Harbor registry


    * add caCert to kubectl get KappControllerConfig in the supervisor cluster or create a config map in the target cluster with an updated Kapp configuration

1. Add registry secret and repository to the target cluster
1. Decide witch profile should be used between lite and full https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/tanzu-build-service-dependencies.html


    * full has tiny and full ubuntu stack, support air-gapped, faster builds, requires additional steps for updating TAP version
    * lite no PHP

1. Configure profile (package values)
1. Install package

Verify:

- Download https://network.tanzu.vmware.com/products/build-service/
- kubectl api-resources | grep 'kpack.io'
- list clusterbuilders
