# ---- products-service ----
# Imagen base liviana de Python.
FROM python:3.12-slim

# Evita archivos .pyc y fuerza logs sin buffer (mejor para contenedores).
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias primero (aprovecha la cache de capas de Docker).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación.
COPY app ./app

# Puerto interno del servicio.
EXPOSE 8001

# Arranca el servidor ASGI.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
