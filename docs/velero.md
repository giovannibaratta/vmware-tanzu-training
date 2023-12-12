# Velero with MinIO

1. Install and configure MinIO (see [here](../ansible/minio/README.md) for an example)
1. Install Velero
1. Annotate pods
1. Configure a backup scheduler or run a one-time backup.

## Install Velero

```sh
velero install \
--provider aws \
--plugins velero/velero-plugin-for-aws:v1.7.1 \
--bucket <BUCKET_NAME> \
--secret-file <PATH_TO_MINIO_CREDENTIALS> \
--use-volume-snapshots=false \
--use-node-agent \
--cacert <PATH_TO_MINIO_CERT> \
--backup-location-config \
region=minio,s3ForcePathStyle="true",s3Url=https://<MINIO_URL>,publicUrl=https://<MINIO_URL>
```

> --use-node-agent enable the use of File System Backup for stateful workloads

> The version of AWS plugin depends on the version of Velero. See [here](https://github.com/vmware-tanzu/velero-plugin-for-aws)
> For Velero and Kubernetes compatibility matrix see [here](See https://github.com/vmware-tanzu/velero#velero-compatibility-matrix)

> cacert used for self-signed certificates has been introduced in version 1.1.0

## Annotate pods

By default, an opt-in approach is used, hence pods must be annotated to enable volume backups.

`backup.velero.io/backup-volumes=YOUR_VOLUME_NAME_1,YOUR_VOLUME_NAME_2,...`

```sh
kubectl patch deployment -n voting-app db --type merge -p '{"spec":{"template":{"metadata":{"annotations":{"backup.velero.io/backup-volumes":"db-data"}}}}}'
```

## One time backup

Start backup
`velero backup create <BACKUP_NAME> --include-namespaces <NAMESPACE_NAME> --wait`

Restore
`velero restore create --from-backup <BACKUP_NAME>`