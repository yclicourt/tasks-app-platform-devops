# Kyverno — politicas de la plataforma

## Que es y por que

Kyverno es el "guardián" del cluster: valida (y puede mutar o bloquear) recursos
antes de que se creen. Es lo que separa "despliego apps" de "opero una plataforma":
las buenas practicas dejan de ser recomendaciones y pasan a ser reglas.

## Politicas incluidas (modo Audit)

1. **disallow-latest-tag** — prohibe imagenes `:latest`. Tu CI ya taggea con el SHA,
   asi que esta politica protege ese habito.
2. **require-resource-limits** — todo contenedor declara cpu/memoria. Sin esto, un
   pod puede comerse el nodo entero.
3. **require-non-root** — nada corre como root. Tu Dockerfile del frontend ya cumple.

## Por que Audit y no Enforce

`failureAction: Audit` registra violaciones en PolicyReports **sin bloquear** nada.
Flujo correcto:
1. Despliega en Audit, revisa `kubectl get policyreport -A`.
2. Arregla tus charts hasta que esten limpios.
3. Cambia a `Enforce`.

Pasar directo a Enforce en un cluster con cosas corriendo es como poner un
guardia nuevo el primer dia: bloquea hasta lo que funciona.

## Ver violaciones

```bash
kubectl get clusterpolicy
kubectl get policyreport -A
```
