# Velero — backups de la plataforma

## Que es y por que

Una plataforma sin backups no es de produccion. Velero respalda dos cosas:
1. **Los recursos del cluster** (Deployments, Services, ConfigMaps...) como YAML.
2. **Los datos de los volumenes** (Postgres!) via file-system backup.

## Detalle importante en k3s

k3s usa `local-path` como storage, que **no soporta VolumeSnapshots**. Por eso no
hay `volumeSnapshotLocation`: los volumenes se respaldan con el node-agent
(restic), que lee los archivos y los sube al object storage. Es mas lento que un
snapshot, pero funciona en cualquier parte.

## Componentes

- **MinIO** (`platform/minio/`): S3-compatible dentro del cluster. En produccion
  seria S3/GCS real; para el homelab, MinIO es lo correcto.
- **Velero** (chart `vmware-tanzu/velero` via ArgoCD): `BackupStorageLocation`
  apuntando a MinIO.
- **Schedule** (`schedules/`): backup diario de `tasks-app` a las 3am, retencion 30 dias.

## Credenciales (hacer una vez)

```bash
kubeseal --fetch-cert --controller-namespace kube-system > pub.pem
cat > cloud.txt <<'CREDS'
[default]
aws_access_key_id = minioadmin
aws_secret_access_key = TU-CLAVE-MINIO
CREDS
kubectl create secret generic cloud-credentials -n velero \
  --from-file=cloud=cloud.txt --dry-run=client -o yaml \
  | kubeseal --cert pub.pem --format yaml > sealed-cloud-credentials.yaml
kubectl apply -f sealed-cloud-credentials.yaml
```

## Operacion

```bash
velero backup get -n velero          # ver backups
velero backup create manual-1 --include-namespaces tasks-app -n velero
velero restore create --from-backup tasks-app-daily-20261019 -n velero
```
