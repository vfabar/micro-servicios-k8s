#!/usr/bin/env bash
#
# build-and-push-ecr.sh
# =====================
# Construye las imágenes de los 3 microservicios y las publica en Amazon ECR.
# Pensado como guía manual para el laboratorio (luego se automatiza con GitHub Actions).
#
# Requisitos: awscli v2 y docker configurados, y credenciales AWS válidas.
#
# Uso:
#   AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-east-1 ./scripts/build-and-push-ecr.sh
#
set -euo pipefail

: "${AWS_ACCOUNT_ID:?Debes exportar AWS_ACCOUNT_ID}"
: "${AWS_REGION:?Debes exportar AWS_REGION}"

SERVICES=("products-service" "inventory-service" "orders-service")
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo ">> Autenticando Docker contra ECR (${REGISTRY})..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"

for svc in "${SERVICES[@]}"; do
  echo ">> Procesando ${svc}..."

  # Crea el repositorio en ECR si aún no existe (idempotente).
  aws ecr describe-repositories --repository-names "${svc}" --region "${AWS_REGION}" >/dev/null 2>&1 \
    || aws ecr create-repository --repository-name "${svc}" --region "${AWS_REGION}" >/dev/null

  # Construye, etiqueta y sube.
  docker build -t "${svc}:latest" "./${svc}"
  docker tag "${svc}:latest" "${REGISTRY}/${svc}:latest"
  docker push "${REGISTRY}/${svc}:latest"

  echo ">> ${svc} publicado en ${REGISTRY}/${svc}:latest"
done

echo ">> Listo. Recuerda reemplazar <ACCOUNT_ID> y <REGION> en los deployment.yaml,"
echo "   o usar: sed -i \"s|<ACCOUNT_ID>|${AWS_ACCOUNT_ID}|g; s|<REGION>|${AWS_REGION}|g\" */k8s/deployment.yaml"
