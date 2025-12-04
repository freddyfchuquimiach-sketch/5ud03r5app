#!/bin/bash
set -e

VERSION=${1:-latest}
echo "Desplegando localmente la versión: $VERSION"

# Aseguramos Minikube
minikube start >/dev/null 2>&1 || true
minikube addons enable ingress >/dev/null 2>&1 || true

# Generamos los manifests con Kustomize directamente (¡sin sed!)
echo "Generando manifests con Kustomize..."
kustomize build deploy/overlays/production > /tmp/5ud03r5app-manifest.yaml

# Aplicamos directamente
echo "Aplicando en el clúster..."
kubectl apply -f /tmp/5ud03r5app-manifest.yaml

# Mostramos estado
echo ""
echo "Despliegue completado!"
kubectl get pods -l app=5ud03r5app
kubectl get svc app-service
echo ""
echo "Accede en: http://5ud03r5app.local"
echo "O con: minikube service app-service --url"