# 📄 Guía de Contexto Técnico y Sistema de Diseño: LabControl

Esta guía contiene la referencia completa del **Backend, Base de Datos, Endpoints y Sistema de Diseño (Apariencia Visual)** de **LabControl**, diseñada para servir como documentación de consulta para el desarrollo de nuevos módulos y aplicaciones (como la **App de TV / Tablero Informativo**).

---

## ⚙️ 1. Infraestructura y Despliegue del Backend

* **Tecnología**: Node.js (Express con ES Modules).
* **Base de Datos**: PostgreSQL 15 ejecutándose dentro de Docker.
* **Puerto de Base de Datos**: `5433` (mapeado en Docker para evitar conflictos con PostgreSQL local).
* **Puerto del Servidor API**: `8080`.
* **URL Base de la API**: `http://localhost:8080/api` (o la IP local de tu máquina en la red: `http://<IP_LOCAL>:8080/api`).

### Comandos de Invocación
```bash
# 1. Iniciar Base de Datos en Docker
cd lab_control_backend
docker-compose up -d

# 2. Iniciar Backend Node.js
npm install
npm run dev
```

---

## 🗄️ 2. Modelo de Base de Datos y Entidades

### 1. `users` (Usuarios)
| Campo | Tipo | Notas |
| :--- | :--- | :--- |
| `id` | UUID | Clave Primaria (Autogenerado v4) |
| `name` | VARCHAR(100) | Nombre completo del alumno/profesor |
| `email` | VARCHAR(100) | Único, utilizado para iniciar sesión |
| `password` | VARCHAR(255) | Cifrado con `bcrypt` |
| `student_id` | VARCHAR(50) | Matrícula / Carnet de estudiante |
| `career` | VARCHAR(100) | Carrera universitaria |
| `role` | VARCHAR(20) | Valores aceptados: `'student'`, `'teacher'`, `'admin'` |

### 2. `equipment_categories` (Categorías)
| Campo | Tipo | Notas |
| :--- | :--- | :--- |
| `id` | UUID | Clave Primaria |
| `name` | VARCHAR(50) | Ejemplos: `Electrónica`, `Cómputo`, `Redes` |

### 3. `equipment` (Equipos de Laboratorio)
| Campo | Tipo | Notas |
| :--- | :--- | :--- |
| `id` | UUID | Clave Primaria |
| `name` | VARCHAR(100) | Nombre del equipo (ej. *Kit Arduino Uno R3*) |
| `category_id` | UUID | Llave Foránea a `equipment_categories` |
| `code` | VARCHAR(50) | Código de inventario único (ej. `EQ-001`) |
| `location` | VARCHAR(150) | Ubicación (ej. *Laboratorio 3 - Planta Baja*) |
| `total_units` | INT | Total de unidades físicas en inventario |
| `available_units` | INT | Unidades libres para reserva ($0 \le \text{available} \le \text{total}$) |
| `image_url` | VARCHAR(255) | URL o path de la imagen del equipo |

### 4. `reservations` (Préstamos)
| Campo | Tipo | Notas |
| :--- | :--- | :--- |
| `id` | UUID | Clave Primaria |
| `user_id` | UUID | Llave Foránea a `users` |
| `equipment_id` | UUID | Llave Foránea a `equipment` |
| `quantity` | INT | Cantidad de unidades prestadas |
| `pickup_date` | TIMESTAMP | Fecha/Hora programada para recogida |
| `return_date` | TIMESTAMP | Fecha/Hora de devolución esperada |
| `status` | VARCHAR(20) | Estados: `'pending'`, `'active'`, `'completed'`, `'cancelled'` |
| `reservation_code` | VARCHAR(100) | Código único para verificación o QR (ej. `RES-12345`) |

---

## 🎨 3. Sistema de Diseño y Apariencia Visual (UI/UX)

La interfaz de **LabControl** utiliza **Material 3** con una paleta de colores universitarios moderna y limpia.

### 🎨 3.1 Paleta de Colores Oficial

```
+-------------------------------------------------------------------+
|  Verde Esmeralda (Primary):       #16A34A | rgb(22, 163, 74)     |
|  Verde Oscuro (Primary Dark):     #15803D | rgb(21, 128, 61)     |
|  Fondo Claro (Background):        #F7F8FA | rgb(247, 248, 250)   |
|  Superficie Tarjetas (Card Bg):   #FFFFFF | rgb(255, 255, 255)   |
|  Texto Principal (Text Primary):  #111827 | rgb(17, 24, 39)      |
|  Texto Secundario (Text Sec):     #6B7280 | rgb(107, 114, 128)   |
+-------------------------------------------------------------------+
|  Estados de Disponibilidad:                                        |
|  - Disponible (Available):        #22C55E | Stock > 2             |
|  - Advertencia (Warning):          #F59E0B | Stock <= 2            |
|  - No Disponible (Unavailable):   #EF4444 | Stock == 0            |
+-------------------------------------------------------------------+
```

### 📐 3.2 Tipografía e Iconografía

* **Estilo General**: Material 3 / Sans-Serif (Inter / Roboto / System Font).
* **Títulos**: `FontWeight.bold`, $16\text{px} - 18\text{px}$, Color `#111827`.
* **Subtítulos y Metadatos**: `FontWeight.normal`, $12\text{px} - 14\text{px}$, Color `#6B7280`.
* **Iconos por Categoría**:
  * **Electrónica**: `Icons.developer_board_rounded` (Placa / Arduino)
  * **Cómputo**: `Icons.laptop_chromebook_rounded` (Laptop)
  * **Redes**: `Icons.router_rounded` (Router)
  * **Ubicación**: `Icons.location_on_outlined`

### 🧱 3.3 Estilos de Componentes Clave

1. **Tarjetas de Equipo (Equipment Cards)**:
   * **Fondo**: `#FFFFFF`
   * **Bordes Redondeados**: `16px` (`BorderRadius.circular(16)`)
   * **Sombra**: Sutil, negro con 5% de opacidad (`Colors.black.withOpacity(0.05)`).
   * **Contenedor de Imagen/Icono**: Caja cuadrada de `60x60px` con fondo `#F7F8FA` y radio de `12px`.
2. **Badges de Estado (Availability Badges)**:
   * **Fondo de Badge**: Color del estado con **12% de opacidad** (`color.withOpacity(0.12)`).
   * **Borde del Badge**: 1px con **30% de opacidad** (`color.withOpacity(0.3)`).
   * **Texto**: `FontWeight.bold`, $11\text{px}$, en color puro del estado.
3. **Botones Principales (Elevated Buttons)**:
   * **Fondo**: `#16A34A` (Verde Esmeralda).
   * **Texto**: `#FFFFFF`, $16\text{px}$, `FontWeight.w600`.
   * **Padding**: `14px` vertical, `24px` horizontal.
   * **Bordes Redondeados**: `12px`.
4. **Campos de Entrada (Input Fields)**:
   * **Fondo**: `#FFFFFF`
   * **Borde deshabilitado/inactivo**: `grey.shade200`
   * **Borde enfocado**: 1.5px `#16A34A`
   * **Border Radius**: `12px`

---

## 📺 4. Guía de Adaptación Visual para la App de TV

Al desarrollar el cliente de **TV / Tablero Informativo**, se recomiendan los siguientes ajustes estéticos para optimizar la visibilidad a distancia (resoluciones 1080p y 4K):

1. **Escala de Texto y Fuentes Ampliadas**:
   * Títulos de sección: $28\text{px} - 36\text{px}$.
   * Nombres de equipos/tarjetas: $20\text{px} - 24\text{px}$.
   * Textos de metadatos: $16\text{px} - 18\text{px}$.
2. **Distribución en Grid (Matriz de Pantalla Ancha)**:
   * Usar diseño tipo **Grid de 3 o 4 columnas** en orientación horizontal 16:9.
3. **Indicadores de Estado Luminosos**:
   * Badges de mayor tamaño con puntos indicadores pulsan/brillantes para reflejar en tiempo real la disponibilidad de los laboratorios desde lejos.

---

## 🔌 5. Catálogo de Endpoints de la API

### 🔑 Autenticación (`/api/auth`)
* `POST /api/auth/login`
  * **Body**: `{ "email": "diego.pardo@universidad.edu", "password": "password123" }`
  * **Respuesta**: Token JWT y datos del usuario.
* `POST /api/auth/register`
* `GET /api/auth/profile` (`Authorization: Bearer <TOKEN>`)

### 📦 Equipos (`/api/equipment`)
* `GET /api/equipment`: Lista de equipos con disponibilidad (`available_units`, `location`, `code`, `category`, etc.).
* `GET /api/equipment/categories`: Lista de categorías.
* `GET /api/equipment/:id`: Detalle del equipo.

### 📋 Reservas (`/api/reservations`)
* `GET /api/reservations`: Lista global de préstamos (útil para la cola de entregas en la TV).
* `GET /api/reservations/user/:userId`: Reservas del usuario.
* `POST /api/reservations`: Crear préstamo.
* `PATCH /api/reservations/:id/status`: Cambiar estado (`active`, `completed`, `cancelled`).

---

## 🔑 Credenciales de Prueba

* **Health check**: `http://localhost:8080/health`
* **Estudiante de Prueba**: `diego.pardo@universidad.edu` / `password123`
* **Administrador de Prueba**: `admin@universidad.edu` / `password123`
