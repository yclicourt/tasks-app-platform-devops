# cert-manager — capa de plataforma

## Que es y por que

Automatiza el ciclo de vida de certificados TLS: los emite, los renueva antes de
que expiren y los guarda como Secrets. Sin esto, el TLS es un proceso manual que
siempre se rompe el dia que el certificado expira un domingo.

## Despliegue (GitOps)

```bash
kubectl -n argocd apply -f application.yaml   # recomendado
# o directo:
kubectl apply -k .
kubectl apply -f clusterissuer.yaml
```

Orden: primero el controller (kustomization), despues el ClusterIssuer.
ArgoCD lo resuelve solo porque el issuer espera a que existan los CRDs.

## Como se usa desde la app

La app declara un `Certificate` (ver `helm/templates/gateway-certificate.yaml`).
cert-manager crea el `Secret platform-tls` y el Gateway lo sirve en el listener
HTTPS. La renovacion es automatica.

## Nota homelab

El issuer es self-signed: el navegador mostrara aviso de certificado no confiable
(haces click-through o importas el CA). Mejora futura: crear una CA propia
(self-signed -> Certificate CA -> ClusterIssuer CA) e importar `ca.crt` una sola
vez en tus maquinas.
