#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Requisitos:
#   - gh CLI instalado y autenticado (gh auth login)
#   - Ejecutar este script parado dentro del repo clonado (usa el remoto origin),
#     o exportar OWNER y REPO manualmente antes de correrlo.
# -----------------------------------------------------------------------------

OWNER="${OWNER:-$(gh repo view --json owner -q .owner.login)}"
REPO="${REPO:-$(gh repo view --json name -q .name)}"

echo "Repositorio destino: ${OWNER}/${REPO}"

create_milestone() {
  local title="$1"
  local description="$2"
  gh api "repos/${OWNER}/${REPO}/milestones" \
    -f title="${title}" \
    -f description="${description}" \
    --silent
  echo "Milestone creado: ${title}"
}

create_issue() {
  local title="$1"
  local milestone="$2"
  local body="$3"
  gh issue create \
    --repo "${OWNER}/${REPO}" \
    --title "${title}" \
    --milestone "${milestone}" \
    --body "${body}"
}

# -----------------------------------------------------------------------------
# Milestones
# -----------------------------------------------------------------------------

create_milestone "Milestone 0: Configuración de repositorio y flujo de trabajo" \
  "Repositorio, protección de main, creación de develop y carga de Milestones/Issues."

create_milestone "Milestone 1: Setup inicial" \
  "Solución .NET 10 Web API con Clean Architecture, frontend React+TS+Tailwind y modelo SQL Server."

create_milestone "Milestone 2: Redis como caché" \
  "Conexión a Redis y caché de productos con patrón cache-aside sobre SQL Server."

create_milestone "Milestone 3: Autenticación y Carrito" \
  "JWT con blocklist de revocación por jti y carrito de compras en Redis Hash."

create_milestone "Milestone 4: Stock y Rankings" \
  "Control de stock con operación atómica (Lua script) y rankings con Sorted Sets."

create_milestone "Milestone 5: Colas y Notificaciones (Redis Streams)" \
  "Cola de pedidos confiable con Redis Streams y Consumer Groups."

create_milestone "Milestone 6: Tests y Documentación" \
  "Tests unitarios/integración, documentación y despliegue."

# -----------------------------------------------------------------------------
# Issues - Milestone 0
# -----------------------------------------------------------------------------

create_issue "Issue 0.1: Crear repositorio y ramas base" \
  "Milestone 0: Configuración de repositorio y flujo de trabajo" \
"**Objetivo:** Tener el repositorio y la estructura de ramas lista antes de cualquier desarrollo.

**Tareas:**
- [ ] Crear repositorio en GitHub.
- [ ] Configurar protección de rama sobre \`main\` (sin push directo, merge solo vía PR, incluyendo administradores).
- [ ] Crear rama \`develop\` a partir de \`main\`.

**Criterio de aceptación:** Repositorio existe con \`main\` protegida y \`develop\` creada desde \`main\`."

create_issue "Issue 0.2: Cargar Milestones e Issues en GitHub" \
  "Milestone 0: Configuración de repositorio y flujo de trabajo" \
"**Objetivo:** Reflejar en GitHub la estructura del roadmap.

**Tareas:**
- [ ] Crear los Milestones 0 a 6 en GitHub.
- [ ] Crear todos los Issues, vinculados a su Milestone correspondiente.

**Criterio de aceptación:** Todos los Issues están cargados en GitHub, cada uno asociado a su Milestone."

# -----------------------------------------------------------------------------
# Issues - Milestone 1
# -----------------------------------------------------------------------------

create_issue "Issue 1.1: Crear solución .NET 10 Web API con Clean Architecture" \
  "Milestone 1: Setup inicial" \
"**Objetivo:** Tener estructura base con capas Api, Application, Domain, Infrastructure.

**Tareas:**
- [ ] Generar proyecto con \`dotnet new webapi\`.
- [ ] Configurar capas y dependencias.
- [ ] Integrar Swagger.

**Criterio de aceptación:** Proyecto compila y expone un endpoint de prueba."

create_issue "Issue 1.2: Crear frontend en React + TS + TailwindCSS" \
  "Milestone 1: Setup inicial" \
"**Objetivo:** Tener estructura base del frontend.

**Tareas:**
- [ ] Generar proyecto con Vite.
- [ ] Configurar TailwindCSS.
- [ ] Crear página inicial con layout básico.

**Criterio de aceptación:** Frontend corre en localhost mostrando layout inicial."

create_issue "Issue 1.3: Configurar SQL Server + EF Core + migraciones iniciales" \
  "Milestone 1: Setup inicial" \
"**Objetivo:** Establecer la fuente de verdad persistente antes de introducir Redis.

**Tareas:**
- [ ] Definir entidades de dominio: Product, Order, Stock (y sus relaciones).
- [ ] Configurar DbContext en Infrastructure, respetando inversión de dependencias.
- [ ] Crear migración inicial y aplicarla contra SQL Server.
- [ ] Definir interfaces de repositorio (IProductRepository, IOrderRepository, IStockRepository) en Application/Domain, con implementación en Infrastructure.

**Criterio de aceptación:** Migración se aplica sin errores; se puede insertar y leer un producto de prueba directamente contra SQL Server, sin pasar por Redis."

# -----------------------------------------------------------------------------
# Issues - Milestone 2
# -----------------------------------------------------------------------------

create_issue "Issue 2.1: Configurar Redis en infraestructura" \
  "Milestone 2: Redis como caché" \
"**Objetivo:** Conexión establecida con Redis.

**Tareas:**
- [ ] Instalar paquete StackExchange.Redis.
- [ ] Configurar conexión en Infrastructure.

**Criterio de aceptación:** API puede guardar y recuperar un valor de prueba en Redis."

create_issue "Issue 2.2: Implementar caché de productos" \
  "Milestone 2: Redis como caché" \
"**Objetivo:** Catálogo de productos servido desde Redis, con SQL Server como respaldo.

**Tareas:**
- [ ] Crear ProductService con patrón cache-aside: primero Redis, si no existe consulta SQL Server y rellena el caché.
- [ ] Endpoint GET /api/products.
- [ ] Definir estrategia de invalidación de caché (TTL o invalidación explícita al actualizar producto).

**Criterio de aceptación:** Productos se sirven desde Redis en menos de 10ms cuando hay hit; en caso de miss, se recuperan desde SQL Server y se cachean."

# -----------------------------------------------------------------------------
# Issues - Milestone 3
# -----------------------------------------------------------------------------

create_issue "Issue 3.1: Autenticación JWT con blocklist de revocación en Redis" \
  "Milestone 3: Autenticación y Carrito" \
"**Objetivo:** Autenticación stateless con capacidad de invalidar tokens antes de su expiración natural.

**Tareas:**
- [ ] Configurar generación y validación de JWT (issuer, audience, expiración, firma), incluyendo un claim jti único por token.
- [ ] Middleware de autenticación/autorización en Api que verifique si el jti está en la blocklist de Redis antes de aceptar el token.
- [ ] Endpoint de logout que agregue el jti del token actual a Redis con TTL igual al tiempo restante hasta expiración.
- [ ] Mecanismo para invalidar manualmente un token filtrado.

**Criterio de aceptación:** Tras logout o invalidación manual, el token es rechazado inmediatamente aunque no haya expirado. El registro en Redis expira automáticamente, sin dejar entradas huérfanas."

create_issue "Issue 3.2: Carrito de compras en Redis" \
  "Milestone 3: Autenticación y Carrito" \
"**Objetivo:** Carrito persistente por usuario, en memoria.

**Tareas:**
- [ ] Crear CartService con Redis Hash (clave por usuario, campos por producto).
- [ ] Endpoints POST /api/cart y GET /api/cart.

**Criterio de aceptación:** Carrito se guarda y recupera correctamente en Redis."

# -----------------------------------------------------------------------------
# Issues - Milestone 4
# -----------------------------------------------------------------------------

create_issue "Issue 4.1: Control de stock con operación atómica (Lua script)" \
  "Milestone 4: Stock y Rankings" \
"**Objetivo:** Evitar overselling sin usar locks distribuidos.

**Tareas:**
- [ ] Implementar script Lua vía EVAL que en una sola operación atómica valide stock >= cantidad y decremente si corresponde.
- [ ] Sincronizar el resultado con SQL Server.
- [ ] Exponer StockService como abstracción, sin filtrar detalles de Redis hacia Application/Domain.

**Criterio de aceptación:** Dos usuarios concurrentes no pueden comprar el mismo producto si queda 1 en stock; no se usa ningún mecanismo de lock."

create_issue "Issue 4.2: Ranking de productos más vendidos" \
  "Milestone 4: Stock y Rankings" \
"**Objetivo:** Mostrar top 10 dinámico.

**Tareas:**
- [ ] Usar Sorted Sets en Redis.
- [ ] Endpoint GET /api/products/top.

**Criterio de aceptación:** Ranking se actualiza en tiempo real."

# -----------------------------------------------------------------------------
# Issues - Milestone 5
# -----------------------------------------------------------------------------

create_issue "Issue 5.1: Cola de pedidos con Redis Streams + Consumer Groups" \
  "Milestone 5: Colas y Notificaciones (Redis Streams)" \
"**Objetivo:** Notificar sistema de logística de forma confiable y persistente, con capacidad de reprocesamiento.

**Tareas:**
- [ ] Crear un Stream de Redis para eventos de pedido confirmado.
- [ ] Configurar un Consumer Group para el servicio de logística.
- [ ] Publicar evento (XADD) al confirmar pedido.
- [ ] Consumidor debe leer con XREADGROUP y confirmar procesamiento con XACK.
- [ ] Definir manejo de mensajes no confirmados (reintentos, XCLAIM o revisión del Pending Entries List).

**Criterio de aceptación:** Mensaje llega al consumidor en menos de 50ms; si el consumidor está caído, el mensaje persiste en el Stream y se procesa al reconectarse, sin pérdida de datos."

# -----------------------------------------------------------------------------
# Issues - Milestone 6
# -----------------------------------------------------------------------------

create_issue "Issue 6.1: Tests unitarios e integración" \
  "Milestone 6: Tests y Documentación" \
"**Objetivo:** Validar servicios críticos.

**Tareas:**
- [ ] Crear pruebas para CartService, ProductService, StockService (incluyendo el script Lua de stock).

**Criterio de aceptación:** Cobertura mínima del 80%."

create_issue "Issue 6.2: Documentación y despliegue" \
  "Milestone 6: Tests y Documentación" \
"**Objetivo:** Proyecto listo para producción.

**Tareas:**
- [ ] Documentar endpoints en Swagger.
- [ ] Crear README con instrucciones.
- [ ] Desplegar en Docker/Azure.

**Criterio de aceptación:** Proyecto corre en contenedor y está documentado."

echo "Listo: 7 Milestones y 15 Issues creados en ${OWNER}/${REPO}."
