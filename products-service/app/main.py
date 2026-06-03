"""
products-service
=================
Microservicio de CATÁLOGO de productos.

Responsabilidad única: exponer información de productos (id, nombre, precio).
No depende de ningún otro servicio (es una "hoja" en el grafo de dependencias).

Otros servicios (orders-service) lo consumen vía HTTP interno para conocer
el precio y el nombre de un producto antes de crear un pedido.
"""
from fastapi import FastAPI, HTTPException

app = FastAPI(
    title="Products Service",
    description="Catálogo de productos de la tienda (Módulo 3 - ISY1101)",
    version="1.0.0",
)

# Base de datos en memoria (didáctica). En un escenario real iría a una BD.
PRODUCTS = {
    1: {"id": 1, "name": "Teclado mecánico",    "price": 39990},
    2: {"id": 2, "name": "Mouse inalámbrico",   "price": 14990},
    3: {"id": 3, "name": "Monitor 27 pulgadas", "price": 159990},
    4: {"id": 4, "name": "Audífonos Bluetooth", "price": 24990},
}


@app.get("/health")
def health():
    """Endpoint de salud usado por las probes de Kubernetes y docker-compose."""
    return {"status": "ok", "service": "products-service"}


@app.get("/products")
def list_products():
    """Devuelve todo el catálogo."""
    return {"products": list(PRODUCTS.values())}


@app.get("/products/{product_id}")
def get_product(product_id: int):
    """Devuelve un producto por id, o 404 si no existe."""
    product = PRODUCTS.get(product_id)
    if product is None:
        raise HTTPException(status_code=404, detail=f"Producto {product_id} no encontrado")
    return product
