#!/usr/bin/env bash
#
# deploy-eks.sh
# =============
# Aplica todos los manifiestos de Kubernetes en el clúster activo (EKS).
# Antes de ejecutar, configura el acceso al clúster:
#   aws eks update-kubeconfig --name <nombre-del-cluster> --region <REGION>
#
# Uso:
#   ./scripts/deploy-eks.sh
#
set -euo pipefail

SERVICES=("products-service" "inventory-service" "orders-service")

for svc in "${SERVICES[@]}"; do
  echo ">> Desplegando ${svc}..."
  kubectl apply -f "./${svc}/k8s/deployment.yaml"
  kubectl apply -f "./${svc}/k8s/service.yaml"
done

echo ">> Esperando a que los pods estén listos..."
kubectl rollout status deployment/products-service
kubectl rollout status deployment/inventory-service
kubectl rollout status deployment/orders-service

echo ">> Despliegue completo. Servicios:"
kubectl get svc -l 'app in (products-service,inventory-service,orders-service)'
