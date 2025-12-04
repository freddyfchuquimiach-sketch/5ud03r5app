#!/bin/bash
set -e

NEW_TAG=${1:-latest}
echo "Nueva versión a desplegar: freddych/5ud03r5app:$NEW_TAG"

# 1. Iniciar Minikube
echo "Iniciando Minikube..."
minikube status | grep -q "Running" || minikube start
minikube addons enable ingress 2>/dev/null || true

# 2. Detectar cuál entorno tiene tráfico actualmente
CURRENT=$(kubectl get svc app-service -o jsonpath='{.spec.selector.version}' 2>/dev/null || echo "green")
if [[ "$CURRENT" == "blue" ]]; then
  IDLE="green"
  ACTIVE="blue"
else
  IDLE="blue"
  ACTIVE="green"
fi

echo "Entorno con tráfico (NO se toca): $ACTIVE"
echo "Entorno inactivo (se actualizará): $IDLE → $NEW_TAG"

# 3. Ruta absoluta al archivo de plantilla (funciona desde cualquier carpeta)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/deployment-template.yaml"

# 4. Aplicar plantilla al entorno inactivo
echo "Desplegando nueva versión en $IDLE..."
sed "s|IMAGE_TAG|$NEW_TAG|g; s/VERSION/$IDLE/g" "$TEMPLATE" | kubectl apply -f -

# 5. Forzar que use exactamente la nueva imagen y recargue pods
kubectl set image deployment/app-$IDLE app=freddych/5ud03r5app:$NEW_TAG --record 2>/dev/null || true
kubectl rollout restart deployment/app-$IDLE 2>/dev/null || true

# 6. Esperar que esté listo
echo "Esperando que $IDLE esté listo..."
kubectl rollout status deployment/app-$IDLE --timeout=180s

# 7. URL para probar la nueva versión
NODE_PORT=$(kubectl get svc app-service-$IDLE -o jsonpath='{.spec.ports[0].nodePort}')
echo ""
echo "PRUEBA LA NUEVA VERSIÓN ($NEW_TAG) AQUÍ (sin afectar producción):"
echo "   http://$(minikube ip):$NODE_PORT"
echo "   o ejecuta: kubectl port-forward svc/app-service-$IDLE 8081:8080"
echo ""

read -p "¿La nueva versión funciona bien? (s/n): " ans
if [[ "$ans" =~ ^[Ss]$ ]]; then
    echo "Haciendo switch: tráfico → $IDLE"
    kubectl patch service app-service -p "{\"spec\":{\"selector\":{\"version\":\"$IDLE\"}}}"
    echo "¡SWITCH COMPLETADO! Ahora $IDLE ($NEW_TAG) es producción"
else
    echo "Rollback: se mantiene $ACTIVE como producción"
fi

# 8. Mostrar estado final
echo ""
echo "=== ESTADO FINAL ==="
kubectl get svc app-service -o jsonpath='{.spec.selector.version}' && echo " ← tiene el tráfico"
echo ""
kubectl get deployment app-blue app-green \
  -o custom-columns=ENTORNO:.metadata.name,IMAGEN:.spec.template.spec.containers[0].image
echo ""
echo "Accede a producción: http://5ud03r5app.local"
echo "¡Listo! Todo funcionando con zero-downtime."