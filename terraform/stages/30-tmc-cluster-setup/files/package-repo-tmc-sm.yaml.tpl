apiVersion: packaging.carvel.dev/v1alpha1
kind: PackageRepository
metadata:
  name: tanzu-mission-control
  namespace: tkg-system
spec:
  fetch:
    imgpkgBundle:
      image: ${tmc_repo_ref}
