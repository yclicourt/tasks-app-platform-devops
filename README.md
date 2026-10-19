# Tasks App — Platform Engineering

Demo end-to-end de plataforma: desde `git push` hasta produccion en Kubernetes,
con todo lo que una plataforma real necesita (no solo la app).

## Flujo completo

```
git push ──▶ GitHub Actions ──▶ Harbor ──▶ values.yaml (tag = SHA)
   lint → test → build → Trivy scan → push → GitOps bump

ArgoCD (app-of-apps) ──▶ sync automatico ──▶ Gateway API ──▶ tu app
   wave 0: sealed-secrets, cert-manager, kyverno
   wave 1: tasks-app, openobserve, minio, velero
   wave 2: kyverno-policies, velero-schedules
```

## Capas de la plataforma

| Capa | Que | Donde |
|---|---|---|
| Apps | Django API + React/Vite | `backend/`, `client/` |
| CI | lint, test, scan, push, bump | `.github/workflows/` |
| CD | ArgoCD app-of-apps | `platform/app-of-apps/` |
| IaC | Terraform (namespace, secrets, sa) | `terraform/` |
| Trafico | Gateway API (Traefik), HTTPS | `helm/templates/gateway*.yaml` |
| Secretos | Sealed Secrets | `helm/templates/*/sealed-secret.yml` |
| TLS | cert-manager (self-signed) | `platform/cert-manager/` |
| Politicas | Kyverno (audit) | `platform/kyverno/` |
| Observabilidad | OpenObserve + OTel | `platform/openobserve/` |
| Backups | Velero + MinIO | `platform/velero/`, `platform/minio/` |

## Estructura del repo

```
├── backend/                  # Django API
├── client/                   # React + Vite
├── helm/                     # Chart (deployments, services, Gateway, HTTPRoutes, SealedSecrets)
├── terraform/                # IaC: namespace, registry secret, service account
├── .github/workflows/        # backend.yml, frontend.yml, terraform.yml
└── platform/                 # Todo lo que hace esto una PLATAFORMA
    ├── app-of-apps/          # Una Application que gobierna a todas las demas
    ├── sealed-secrets/       # Controller para secretos cifrados en git
    ├── cert-manager/         # TLS automatico
    ├── kyverno/              # Politicas (no latest, limits, non-root)
    ├── openobserve/          # Metricas, logs y trazas
    ├── minio/ + velero/      # Backups programados
    └── ...
```

## Bootstrap en k3s (orden importa)

```bash
# 1. Cluster k3s + Gateway API
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml
kubectl apply -f - <<'YAML'   # habilita el provider Gateway API en el Traefik de k3s
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata: { name: traefik, namespace: kube-system }
spec:
  valuesContent: |-
    providers:
      kubernetesGateway: { enabled: true }
YAML

# 2. ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. La plataforma se instala sola desde aqui
kubectl -n argocd apply -f platform/app-of-apps/appproject.yaml
kubectl -n argocd apply -f platform/app-of-apps/root.yaml
```

Variables de GitHub Actions requeridas: `HARBOR_REGISTRY`, `DB_NAME`, `DB_USER`;
secrets: `HARBOR_USERNAME`, `HARBOR_PASSWORD`, `SECRET_KEY`, `PAT_TOKEN`.

## Decisiones documentadas

- **Gateway API en vez de Ingress**: Ingress esta congelado; Gateway API separa
  roles (plataforma vs app) y es portable entre implementaciones.
- **OpenObserve en vez de Prometheus+Loki+Tempo**: un binario, OTLP nativo,
  storage columnar eficiente para homelab.
- **Kyverno en Audit primero**: las politicas se observan antes de bloquear.
- **Velero con restic**: local-path (k3s) no soporta VolumeSnapshots.

- **Sin Backstage (por ahora)**: es el portal del developer, no la plataforma en si.
  Su valor esta en el catalogo, los templates y la adopcion real de un equipo; en un
  homelab seria el componente mas pesado del cluster y un cascaron vacio. El
  "paved road" que un portal expondria (CI, GitOps, politicas) ya existe debajo;
  el portal se agrega cuando hay developers que lo consuman.
- **Sin Crossplane**: es una *alternativa* a Terraform, no un complemento, y este
  repo ya tiene Terraform funcionando (modulos, remote state, CI). Su superpoder es
  componer APIs de nube publica (RDS, buckets) para self-service de developers; en
  un k3s homelab no hay esas APIs que abstraer. Dos herramientas de IaC implican
  dos fuentes de verdad.
