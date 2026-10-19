# App-of-apps — la plataforma se gestiona sola

## Que es y por que

Sin esto, cada componente de la plataforma (ArgoCD lo instala a mano o con
kubectl). Con app-of-apps, **una sola Application (`platform-root`) contiene a
todas las demas**: agregas un archivo en `applications/` y ArgoCD lo despliega.
La plataforma entera queda declarada en git: reproducible con dos comandos.

```
platform-root
├── sealed-secrets   (wave 0 - fundacion)
├── cert-manager     (wave 0 - fundacion)
├── kyverno          (wave 0 - fundacion)
├── tasks-app        (wave 1 - workloads)
├── openobserve      (wave 1 - workloads)
└── kyverno-policies (wave 2 - despues del controller)
```

## Bootstrap (una sola vez)

```bash
kubectl -n argocd apply -f appproject.yaml
kubectl -n argocd apply -f root.yaml
```

## Agregar un componente nuevo

1. Crea su directorio bajo `platform/<nombre>/` (manifiestos o values).
2. Agrega `platform/app-of-apps/applications/<nombre>.yaml` con su source.
3. Commit + push. ArgoCD hace el resto.
