# ---------- Stage 1: Build -------------
FROM registry.local:5443/oficial-images/node:22-alpine AS build 

WORKDIR /app

# Definimos que esperamos este argumento durante el build
ARG VITE_API_URL_PLACEHOLDER

# Lo convertimos en variable de entorno para que Vite lo pueda leer
ENV VITE_API_URL_PLACEHOLDER=$VITE_API_URL_PLACEHOLDER

# Instalamos pnpm globalmente una sola vez
RUN npm install -g pnpm@10.33.0

# Copiamos archivos de dependencias
COPY package.json pnpm-lock.yaml* ./

# Instalación optimizada
RUN pnpm install --frozen-lockfile

# Copiamos el resto del código
COPY . .

# Generamos el build de producción
RUN pnpm run build

# ---------- Stage 2: Servir con Nginx -------------
FROM registry.local:5443/oficial-images/nginx:alpine

# Copiamos la configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Preparamos los archivos para correr como usuario no-root (nginx)
# El puerto debe ser > 1024 para usuarios sin privilegios
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

# Copiamos los archivos estáticos desde la etapa de build
# Importante: verifica si tu build sale en /app/dist o /app/build
COPY --from=build /app/dist/ /usr/share/nginx/html

# Copiamos el script de reemplazo
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Definimos el entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Importante: Nginx debe estar configurado para escuchar en el 8080 en nginx.conf
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]