# Observabilidad de la plataforma — OpenObserve

Un solo binario que concentra metricas, logs y trazas. Habla OTLP nativo,
asi que la instrumentacion estandar de OpenTelemetry llega directa, sin adaptadores.

## Arquitectura

```
React (OTel JS) ──trace context (W3C)──> Django (OTel Python) ──OTLP──> OpenObserve
                                                    │
k8s logs/metricas ── openobserve-collector ──OTLP───┘
                                                    v
                                          o2-tasks.local (via Gateway API)
```

## Fase 1 — OpenObserve (este directorio)

```bash
helm repo add openobserve https://charts.openobserve.ai
helm repo update
# Edita values.yaml con tus credenciales primero
helm install o2 openobserve/openobserve-standalone -n openobserve --create-namespace -f values.yaml
kubectl -n openobserve apply -f httproute.yaml
```

Abre `http://o2-tasks.local` (agrega el host a tu /etc/hosts apuntando al cluster).

## Fase 2 — Colector del cluster (pendiente)

```bash
# Prerrequisitos: cert-manager + OpenTelemetry Operator
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.1/cert-manager.yaml
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

helm install o2c openobserve/openobserve-collector -n openobserve-collector --create-namespace \
  --set k8sCluster=k3s-homelab \
  --set exporters."otlphttp/openobserve".endpoint=http://o2-openobserve-standalone.openobserve:5080/api/default \
  --set exporters."otlphttp/openobserve".headers.Authorization="Basic $(echo -n 'admin@tasks.local:TuClave' | base64)" \
  --set exporters."otlphttp/openobserve".headers."stream-name"=k8s_logs
```

## Fase 3 — Trazas distribuidas (pendiente)

- Backend Django: `opentelemetry-distro` + exportador OTLP apuntando a OpenObserve.
- Frontend React: `@opentelemetry/sdk-trace-web` con `W3CTraceContextPropagator`.
- El mismo `trace_id` viajara del click en el frontend hasta la query en Postgres,
  visible en la UI de OpenObserve correlacionado con logs y metricas.
