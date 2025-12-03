#!/bin/bash
set -e

NEW_TAG=${1:-latest}
echo "Nueva versión a desplegar: freddych/5ud03r5app:$NEW_TAG"

# 1. Asegurar que Minikube esté corriendo
echo "Iniciando Minikube..."
minikube status | grep -q "Running" || minikube start

# 2. Habilitar ingress (solo la primera vez)
minikube addons enable ingress 2>/dev/null || true

# 3. Aplicar Blue (versión actual = latest de main)
echo "Desplegando versión actual como BLUE..."
sed "s|IMAGE_TAG|latest|g" deployment-template.yaml | sed "s/version/blue/g" | kubectl apply -f -

# 4. Aplicar Green (nueva versión)
echo "Desplegando nueva versión como GREEN: $NEW_TAG"
sed "s|IMAGE_TAG|$NEW_TAG|g" deployment-template.yaml | sed "s/version/green/g" | kubectl apply -f -

# 5. Aplicar Service apuntando a Blue inicialmente
kubectl apply -f service.yaml

# 6. Esperar que Green esté listo
echo "Esperando que Green esté listo..."
kubectl rollout status deployment/app-green --timeout=120s

# 7. Obtener URL temporal para probar Green
GREEN_IP=$(minikube ip)
echo ""
echo "PRUEBA LA NUEVA VERSIÓN (Green) AQUÍ:"
echo "http://$GREEN_IP:$(kubectl get svc app-service-green -o jsonpath='{.spec.ports[0].nodePort}')"
echo ""
echo "O con port-forward rápido:"
echo "kubectl port-forward svc/app-service-green 8081:80"
echo ""

read -p "¿La nueva versión funciona bien? (s/n): " respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo "Cambiando tráfico a Green (producción)..."
    kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'
    echo "¡DESPLIEGUE EXITOSO! Green ahora es producción"
    echo "Accede en: http://5ud03r5app.local"
    echo "add to /etc/hosts: $(minikube ip) 5ud03r5app.local"
else
    echo "Rollback automático a Blue..."
    kubectl patch service app-service -p '{"spec":{"selector":{"version":"blue"}}}'
    echo "Se mantuvo la versión anterior (Blue)"
fi

# 8. Mostrar estado final
echo ""
kubectl get all -l app=5ud03r5app
