#!/bin/bash

# Tag de la nueva versión
NEW_TAG=$1
if [[ -z "$NEW_TAG" ]]; then
  echo "Uso: ./switch-blue-green.sh <nuevo-tag>"
  exit 1
fi

# Obtener entorno activo
ACTIVE=$(kubectl get configmap active-env -o jsonpath='{.data.active}')
if [[ "$ACTIVE" == "blue" ]]; then
  INACTIVE="green"
else
  INACTIVE="blue"
fi

echo "Entorno activo actual: $ACTIVE"
echo "Actualizando entorno inactivo: $INACTIVE con tag $NEW_TAG"

# Actualizar Deployment inactivo
kubectl set image deployment/app-$INACTIVE app=freddych/5ud03r5app:$NEW_TAG

# Esperar que los pods estén listos
kubectl rollout status deployment/app-$INACTIVE

# Cambiar Service al nuevo entorno
kubectl patch service app-service -p "{\"spec\":{\"selector\":{\"version\":\"$INACTIVE\"}}}"

# Actualizar ConfigMap para reflejar el nuevo entorno activo
kubectl patch configmap active-env -p "{\"data\":{\"active\":\"$INACTIVE\"}}"

echo "Switcheo completo. $INACTIVE ahora está en producción."
