# Sealed Secrets controller — capa de plataforma

## Que es y por que

Los `SealedSecret` de tu chart (`helm/templates/*/sealed-secret.yml`) son secretos
cifrados que SI se pueden commitear a git. Pero cifrado no sirve de nada sin quien
descifre: el **controller** corre en el cluster, guarda su clave privada como un
Secret de Kubernetes, y convierte cada `SealedSecret` en un `Secret` normal que tus
Deployments ya consumen. Sin controller, esos YAML son letra muerta.

Flujo:

```
tu laptop: kubeseal --cert pub.pem < secret.yaml  -->  SealedSecret (git)
cluster:   controller (clave privada)             -->  Secret normal (solo en etcd)
```

## Despliegue (GitOps)

```bash
# Opcion A: via ArgoCD (recomendado, la plataforma se gestiona sola)
kubectl -n argocd apply -f application.yaml
# Opcion B: directo
kubectl apply -k .
```

## ATENCION: tus SealedSecrets actuales NO van a descifrar con un controller nuevo

Cada controller genera su propio par de claves. Tus `sealed-secret.yml` fueron
cifrados con la clave publica de OTRO controller. Al desplegar uno nuevo, veras
en sus logs `no key could decrypt` y los Secrets no se crearan.

Soluciones (una de las dos):

**A. Si tienes backup de la clave privada anterior** (Secret `sealed-secrets-key`
del namespace kube-system del cluster viejo): aplicalo ANTES de instalar el
controller nuevo, con el label `sealedsecrets.bitnami.com/sealed-secrets-key=active`.
El controller la adopta y tus secretos existentes siguen funcionando.

**B. Re-sellar con la clave del controller nuevo** (lo normal si no hay backup):

```bash
# 1. Trae el certificado publico del controller nuevo
kubeseal --fetch-cert \
  --controller-name sealed-secrets-controller \
  --controller-namespace kube-system > newcert.pem

# 2. Re-sella cada secreto (repite por backend y postgres)
kubeseal --cert newcert.pem --format yaml \
  --namespace tasks-app --name backend-tasks-secret \
  < backend-secret.yaml > helm/templates/backend/sealed-secret.yml
```

## Verificar

```bash
kubectl -n kube-system get deploy sealed-secrets-controller
kubectl -n tasks-app get secrets  # backend-tasks-secret y postgres-db-secret deben existir
```
