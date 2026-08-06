# --- ETAPA 1: Builder ---
FROM registry.local:5443/oficial-images/python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 🔥 OPTIMIZACIÓN ETAPA 1: Forzar a APT a mantener los paquetes en la caché del Builder
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=shared \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=shared \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev

RUN pip install --upgrade pip

COPY requirements.txt .

# Caché para las dependencias de Python
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --prefix=/install -r requirements.txt gunicorn


# --- ETAPA 2: Final ---
FROM registry.local:5443/oficial-images/python:3.12-slim

WORKDIR /app

# 🔥 OPTIMIZACIÓN ETAPA 2: Forzar a APT a mantener los paquetes en la caché de la imagen Final
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Aquí se ejecuta el update, el upgrade (para parchar Trivy) y la instalación de libpq5
RUN --mount=type=cache,target=/var/cache/apt,sharing=shared \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=shared \
    apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    libpq5

# Copiamos las librerías limpias desde el builder
COPY --from=builder /install /usr/local

# Configuración de seguridad y estructura de directorios
RUN adduser --disabled-password --gecos "" admbas && \
    mkdir -p /app/staticfiles && \
    chown -R admbas:admbas /app

COPY . .

RUN chown -R admbas:admbas /app

RUN python manage.py collectstatic --noinput

USER admbas

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--timeout","90" ,"--workers", "2", "django_crud_api.wsgi:application"]