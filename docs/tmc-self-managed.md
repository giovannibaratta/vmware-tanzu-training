## Installation (TKGs)

[Install TMC SM](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/install-tmc-sm.html)

1. Install cert manager
   ```bash
   kubectl create ns tkg-packages
   tanzu package repository add tanzu-standard --url projects.registry.vmware.com/tkg/packages/standard/repo:v2.2.0 --namespace tkg-packages
   tanzu package install cert-manager -p cert-manager.tanzu.vmware.com -n tkg-packages -v 1.10.2+vmware.1-tkg.1
   ```
1. Create cluster issuer
1. Retrieve cluster issuer CA cert
   ```bash
   kubectl get secret -n cert-manager self-signed-root-ca-tls -o jsonpath='{.data.tls\.crt}' | base64 -d
   ```
1. Relocate images to private registry using TMC installer deployed in the **jumpbox**
1. Relocate Tanzu packages to private registry
1. Configure Kapp controller to trust CA of the private registry. See [this](https://carvel.dev/kapp-controller/docs/v0.45.0/controller-config/) for more details.
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     # Name must be `kapp-controller-config` for kapp controller to pick it up
     name: kapp-controller-config
     # Namespace must match the namespace kapp-controller is deployed to
     namespace: tkg-system
   stringData:
     # A cert chain of trusted ca certs.
     caCerts: |
       -----BEGIN CERTIFICATE-----
       -----END CERTIFICATE-----
   ```
1. Reload Kapp controller
   ```bash
   kubectl delete pod -n tkg-system -l app=kapp-controller
   ```
1. Add TMC SM repository
   ```bash
   kubectl create ns tmc-local
   tanzu package repository add tanzu-mission-control-packages --url "harbor.h2o-2-22574.h2o.vmware.com/tmc-sm/package-repository:1.1.0" --namespace tmc-local
   ```
1. Label NS
   ```bash
   kubectl label ns tmc-local pod-security.kubernetes.io/enforce=privileged
   ```
1. Prepare values file
   1. Add all the CAs for self-hosted services like Harbor, IDP, Git and TMC in `trustedCAs`
   1. Allocate a static IP address and setup DNS entries
1. Install TMC SM package
   ```bash
   tanzu package install tanzu-mission-control -p "tmc.tanzu.vmware.com" --version 1.1.0 --values-file tmc-sm-v1.1.0-values.yaml --namespace tmc-local
   ```
1. Upload Tanzu standard packages and cluster inspection dependencies. See [this](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/tanzu-conf-images.html) for more details
1. Register the supervisor
   1. Install agent config to add trust in the supervisor
   1. Start registration procedure from TMC and copy the link
   1. Paste the link in the vCenter
   1. After a few minutes this is the expected result in the supervisor cluster
   ```bash
   # TMC SM 1.1, TKGs 2.2, vSphere 8u2
   ➜ kubectl get pods -n svc-tmc-c8
   NAME                                          READY   STATUS      RESTARTS   AGE
   agent-updater-55b787fb7f-nbfpt                1/1     Running     0          3m48s
   agentupdater-workload-28455003-cx4g2          0/1     Completed   0          13s
   cluster-health-extension-7bb8486d49-lpdxb     1/1     Running     0          2m37s
   domain-local-ds-6s87p                         1/1     Running     0          5m10s
   domain-local-ds-7vnt4                         1/1     Running     0          5m10s
   domain-local-ds-x4fd4                         1/1     Running     0          5m10s
   extension-manager-74999899d4-clsd4            1/1     Running     0          3m49s
   extension-updater-84c5f7b6bf-2psk6            1/1     Running     0          3m52s
   intent-agent-59dc656f6d-86lwh                 1/1     Running     0          2m29s
   sync-agent-686cf5cdd7-gdnsc                   1/1     Running     0          2m32s
   tmc-agent-installer-28455003-8gl47            0/1     Completed   0          13s
   tmc-auto-attach-7ccbdd844f-bkgmg              1/1     Running     0          2m30s
   vsphere-resource-retriever-7644d68c8d-llsw8   1/1     Running     0          2m26s
   ```

## Add trust for private registry in workload cluster

> Tested on: TMC SM 1.1

> Certificate specified in the values file of TMC are automatically added to newly created cluster

1. Create a secret like the one below in the supervisor in the same namespace in which the workload cluster will be deployed
   ```yaml
   apiVersion: v1
   data:
     my-registry: <double base64 encoded cert>
     my-root-ca: <double base64 encoded cert>
   kind: Secret
   metadata:
     name: <cluster-name>-user-trusted-ca-secret
     namespace: <vsphere-namespace>
   type: Opaque
   ```
1. While creating the cluster in TMC, in the last section "Additional cluster configuration", click "Add trusted CA" and add the name of the fields in the data block of the previously created secret (e.g. my-root-ca)

[Integrate a TKGs Cluster with a Private Container Registry](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-EC2C9619-2898-4574-8EF4-EA66CFCD52B9.html?hWord=N4IghgNiBc4CZwJYBdEHsB2kAqAnArgM7ICmcAwgIKEgC+QA#v1beta1-api-example-3)

## Attach a cluster

1. Start the procedure from TMC
1. Apply the manifest with the link provided by TMC

## Backup & restore

[Backing up and restoring TMC Self-Managed](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/backup.html)
[Velero Plugin for CSI compatibility matrix](https://github.com/vmware-tanzu/velero-plugin-for-csi#compatibility)

The procedure highlighted below differs from the procedure documented in the link above. The main difference is the objects that are backed up by Velero. Instead of including the tmc-local, the whole cluster is included (expect for a few system objects). Furthermore, the procedure does not use the Velero Plugin for vSphere.

> The procedure requires an object storage (e.g. MinIO) to store the objects included in the backup by Velero.

### Prerequisites

1.  Install Velero client on the **jumpbox**

1.  Relocate Velero and MinIO images

    ```bash
    TARGET_REGISTRY="harbor.h2o-2-22574.h2o.vmware.com"
    PLATFORM="linux/amd64"
    VELERO_VERSION="v1.11.1"
    # Empty string means pull from Docker Hub
    # If a value is provided, it must end with /
    VELERO_SOURCE_REGISTRY="csp-dev-docker.artifactory.eng.vmware.com/"
    VELERO_AWS_VERSION="v1.7.0"
    # Empty string means pull from Docker Hub
    # If a value is provided, it must end with /
    VELERO_AWS_SOURCE_REGISTRY=""

    # minio/mc
    docker pull csp-dev-docker.artifactory.eng.vmware.com/minio/mc:latest --platform=${PLATFORM}
    docker tag csp-dev-docker.artifactory.eng.vmware.com/minio/mc:latest ${TARGET_REGISTRY}/library/minio/mc:latest
    docker push ${TARGET_REGISTRY}/library/minio/mc:latest

    # velero/velero
    docker pull ${VELERO_SOURCE_REGISTRY}velero/velero:${VELERO_VERSION} --platform=${PLATFORM}
    docker tag ${VELERO_SOURCE_REGISTRY}velero/velero:${VELERO_VERSION}   ${TARGET_REGISTRY}/library/velero/velero:${VELERO_VERSION}
    docker push  ${TARGET_REGISTRY}/library/velero/velero:${VELERO_VERSION}

    # velero/velero-plugin-for-aws
    docker pull ${VELERO_AWS_SOURCE_REGISTRY}velero/velero-plugin-for-aws:${VELERO_AWS_VERSION} --platform=${PLATFORM}
    docker tag ${VELERO_AWS_SOURCE_REGISTRY}velero/velero-plugin-for-aws:${VELERO_AWS_VERSION} ${TARGET_REGISTRY}/library/velero/velero-plugin-for-aws:${VELERO_AWS_VERSION}
    docker push ${TARGET_REGISTRY}/library/velero/velero-plugin-for-aws:${VELERO_AWS_VERSION}

    # velero/velero-restore-helper
    docker pull ${VELERO_SOURCE_REGISTRY}velero/velero-restore-helper:${VELERO_VERSION} --platform=${PLATFORM}
    docker tag ${VELERO_SOURCE_REGISTRY}velero/velero-restore-helper:${VELERO_VERSION} ${TARGET_REGISTRY}/library/velero/velero-restore-helper:${VELERO_VERSION}
    docker push ${TARGET_REGISTRY}/library/velero/velero-restore-helper:${VELERO_VERSION}
    ```

1.  Create bucket in MinIO (can be skipped if the bucket has already been created)

    1. Prepare manifest for creating the bucket

       ```bash
       TARGET_REGISTRY="harbor.h2o-2-22574.h2o.vmware.com"
       MINIO_IP_OR_FQDN="10.220.36.15"

       kubectl create ns velero
       kubectl label ns velero pod-security.kubernetes.io/enforce=privileged

       cat > prepare-minio.yaml <<EOF
       apiVersion: batch/v1
       kind: Job
       metadata:
         namespace: velero
         name: minio-setup
         labels:
           component: minio
       spec:
         template:
           metadata:
             name: minio-setup
           spec:
             restartPolicy: OnFailure
             volumes:
             - name: config
               emptyDir: {}
             containers:
             - name: mc
               image: ${TARGET_REGISTRY}/library/minio/mc:latest
               imagePullPolicy: IfNotPresent
               command:
               - /bin/sh
               - -c
               - "mc --config-dir=/config config host add velero http://${MINIO_IP_OR_FQDN}:9000 minioadmin minioadmin && mc --config-dir=/config mb -p velero/velero"
               volumeMounts:
               - name: config
                 mountPath: "/config"
       EOF

       ```

    1. Apply the manifest

       ```bash
       kubectl apply -f prepare-minio.yaml
       ```

    1. Check logs of MinIO setup

       ```bash
       kubectl logs -n velero jobs/minio-setup --all-containers
       ```

### Backup

1.  Exclude resource from backup

    1. Exclude TMC secrets
       ```bash
       kubectl label secret client.oauth.pinniped.dev-auth-manager-pinniped-oidc-client-client-secret-generated velero.io/exclude-from-backup=true -n tmc-local
       kubectl label secrets --field-selector type=storage.pinniped.dev/oidc-client-secret velero.io/exclude-from-backup=true -n tmc-local
       ```

1.  Create a file containing the credentials used by Velero to access the storage

    ```
    [default]
    aws_access_key_id = <ACCESS_ID>
    aws_secret_access_key = <ACCESS_KEY>
    ```

1.  Install Velero

    1. Trigger installation

       ```bash
       TARGET_REGISTRY="harbor.h2o-2-22574.h2o.vmware.com"
       MINIO_IP_OR_FQDN="10.220.36.15"

       velero install \
          --image ${TARGET_REGISTRY}/library/velero/velero:${VELERO_VERSION} \
          --plugins ${TARGET_REGISTRY}/library/velero/velero-plugin-for-aws:${VELERO_AWS_VERSION} \
          --provider aws \
          --bucket velero \
          --use-volume-snapshots false \
          --use-node-agent \
          --secret-file ./credentials-velero \
          --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://${MINIO_IP_OR_FQDN}:9000 \
          --default-volumes-to-fs-backup
       ```

    1. Verify that the backup location is available
       ```bash
       velero backup-location get
       kubectl describe backupstoragelocations -n velero default
       ```

1.  Configure backup schedule
    1. Create a backup
       ```bash
       velero create backup tmc-cluster \
         --exclude-namespaces 'vmware-system-auth,vmware-system-cloud-provider,vmware-system-csi,vmware-system-tkg,vmware-system-tmc,default,kube-node-lease,kube-public,velero,tkg-system,gitlab' \
         --include-cluster-resources
       ```

      > `kube-system` must not be excluded from the backup
    1. Verify backup
       ```bash
       velero backup describe tmc-cluster
       velero backup logs tmc-cluster
       ```

### Restore

1. Install Velero

   1. Trigger installation

      ```bash
      TARGET_REGISTRY="harbor.h2o-2-22574.h2o.vmware.com"
      MINIO_IP_OR_FQDN="10.220.36.15"

      velero install \
         --image ${TARGET_REGISTRY}/library/velero/velero:${VELERO_VERSION} \
         --plugins ${TARGET_REGISTRY}/library/velero/velero-plugin-for-aws:${VELERO_AWS_VERSION} \
         --provider aws \
         --bucket velero \
         --use-volume-snapshots false \
         --use-node-agent \
         --secret-file ./credentials-velero \
         --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://${MINIO_IP_OR_FQDN}:9000 \
         --default-volumes-to-fs-backup
      ```

   1. Verify that the backup location is available
      ```bash
      velero backup-location get
      kubectl describe backupstoragelocations -n velero default
      ```

1. Configure Velero to use image hosted in private registry for item restore

   1. Prepare the manifest
      ```bash
      TARGET_REGISTRY="harbor.h2o-2-22574.h2o.vmware.com"

      cat > configure-velero-restore-image.yaml <<EOF
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: fs-restore-action-config
        namespace: velero
        labels:
          velero.io/plugin-config: ""
          velero.io/pod-volume-restore: RestoreItemAction
      data:
        image: ${TARGET_REGISTRY}/library/velero/velero-restore-helper:${VELERO_VERSION}
        cpuRequest: 200m
        memRequest: 128Mi
        cpuLimit: 200m
        memLimit: 128Mi
        secCtxRunAsUser: "1001"
        secCtxRunAsGroup: "999"
        secCtxAllowPrivilegeEscalation: "false"
        secCtx: |
           capabilities:
             drop:
             - ALL
             add: []
           allowPrivilegeEscalation: false
           readOnlyRootFilesystem: true
           runAsUser: 1001
           runAsGroup: 999
      EOF

      ```

   1. Apply the manifest
      ```bash
      kubectl apply -f configure-velero-restore-image.yaml
      ```

1. Restore the backup
   ```bash
   velero restore create --from-backup tmc-cluster
   ```

1. Wait a few minutes until all the pods are Running again. CrashLoopBackOff errors are expected for a few minutes.

## Additional notes

- If you are deploying an Harbor registry for the first time, you might need to upload some public available packages required for the installation to the private registry. See [this](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-35EB7EB7-7B4F-4C01-A4C5-551D8C0D4409.html) link for more details.

## FAQ

**<i> How to let the kapp-controller trust a self-signed certificate of the Harbor registry ?</i>**

The certificate can be injected using a secret or a config map, see [here](https://carvel.dev/kapp-controller/docs/latest/controller-config/) for more details .

**<i> The pods are failing because the secrets containing TLS certificate can not be found</i>**

Verify if the `certificaterequests` CRD have been created in the namespace used to install TMC. Verify that the issuer specified in the values file is of type ClusterIssuer.

**<i> Internal error while logging in </i>**

Check the landing service logs, if the error is due an invalid securecookie, the pod must be restarted.

```bash
kubectl logs landing-service-server-5d4459bb5c-fgdlk  --since=1m -f | jq
...
securecookie: the value is not valid
...
```

**<i> Internal error (FailedPrecondition) while create a cluster </i>**

```bash
API Error: Failed to create cluster: rpc error: code = FailedPrecondition desc = management cluster or intent agent is not healthy:failed to create the cluster (failed precondition)
```

1. Connect to the supervisor nodes via ssh
1. Restart the intent-agent pods
