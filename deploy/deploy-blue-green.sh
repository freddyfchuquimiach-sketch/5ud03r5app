#!/bin/bash
set -e

NEW_TAG=${1:-latest}
echo "Nueva versión a desplegar: freddych/5ud03r5app:$NEW_TAG"

# 1. Iniciar Minikube
minikube status | grep -q "Running" || minikube start
minikube addons enable ingress 2>/dev/null || true

# 2. Detectar cuál es el entorno actual con tráfico
CURRENT=$(kubectl get svc app-service -o jsonpath='{.spec.selector.version}' 2>/dev/null || echo "blue")
echo "Entorno actual con tráfico: $CURRENT (esto será el que NO toquemos)"

if [[ "$CURRENT" == "blue" ]]; then
  IDLE="green"
  ACTIVE="blue"
else
  IDLE="blue"
  ACTIVE="green"
fi

echo "Vamos a actualizar el entorno inactivo: $IDLE"
echo "El entorno activo ($ACTIVE) NO será tocado → cero downtime"

# 3. Desplegar solo el entorno inactivo con la nueva versión
echo "Desplegando nueva versión en $IDLE..."
sed "s|IMAGE_TAG|$NEW_TAG|g; s/VERSION/$IDLE/g" deployment-template.yaml | kubectl apply -f -

# 4. Aplicar los servicios del entorno inactivo (NodePort)
kubectl apply -f service.yaml

# 5. Esperar que el nuevo esté listo
echo "Esperando que $IDLE esté listo..."
kubectl rollout status deployment/app-$IDLE --timeout=180s

# 6. URL para probar el nuevo entorno
NODE_PORT=$(kubectl get svc app-service-$IDLE -o jsonpath='{.spec.ports[0].nodePort}')
echo ""
echo "PRUEBA LA NUEVA VERSIÓN AQUÍ (sin afectar producción):"
echo "http://$(minikube ip):$NODE_PORT"
echo "o con: kubectl port-forward svc/app-service-$IDLE 8080:80"
echo ""

read -p "¿La nueva versión ($NEW_TAG) funciona bien? (s/n): " respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo "Haciendo switch: $IDLE → producción"
    kubectl patch service app-service -p "{\"spec\":{\"selector\":{\"version\":\"$IDLE\"}}}"
    echo "¡SWITCH COMPLETADO! Ahora $IDLE es producción"
else
    echo "Rollback: se mantiene $ACTIVE como producción"
fi

echo ""
echo "Estado final:"
kubectl get pods,svc -l app=5ud03r5app