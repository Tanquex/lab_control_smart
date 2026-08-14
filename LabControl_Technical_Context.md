# 📄 Guía de Contexto Técnico: LabControl (Backend & API Reference)

Esta guía contiene la referencia completa del **Backend, Base de Datos y Endpoints** de **LabControl**, diseñada para servir como documentación de consulta para la creación de nuevos clientes (como la **App de TV / Tablero Informativo**).

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
| `role` | VARCHAR(20) | Valore aceptados: `'student'`, `'teacher'`, `'admin'` |

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

## 🔌 3. Catálogo de Endpoints de la API

### 🔑 Autenticación (`/api/auth`)
* `POST /api/auth/login`
  * **Body**: `{ "email": "diego.pardo@universidad.edu", "password": "password123" }`
  * **Respuesta**: Token JWT y datos del usuario.
* `POST /api/auth/register`
  * **Body**: Datos de nuevo usuario.
* `GET /api/auth/profile`
  * **Headers**: `Authorization: Bearer <TOKEN>`

### 📦 Equipos (`/api/equipment`)
Ideal para consumir desde la app de TV para mostrar el stock en tiempo real:
* `GET /api/equipment`
  * **Respuesta**: Lista completa de equipos con su disponibilidad (`available_units`, `total_units`, `location`, etc.).
* `GET /api/equipment/categories`
  * **Respuesta**: Lista de categorías registradas.
* `GET /api/equipment/:id`
  * **Respuesta**: Detalle de un equipo en particular.

### 📋 Reservas (`/api/reservations`)
Ideal para mostrar la cola de turnos y devoluciones en la pantalla de TV:
* `GET /api/reservations`
  * **Respuesta**: Lista global de todas las reservas de los laboratorios (estado, usuario, equipo, horarios).
* `GET /api/reservations/user/:userId`
  * **Respuesta**: Reservas específicas de un alumno.
* `POST /api/reservations`
  * **Body**: `{ "equipmentId": "...", "quantity": 1, "pickupDate": "...", "returnDate": "..." }`
* `PATCH /api/reservations/:id/status`
  * **Body**: `{ "status": "active" }` (cambiar a activo, completado o cancelado).

---

## 🔑 Credenciales de Prueba

* **Servicio Health check**: `http://localhost:8080/health`
* **Estudiante de Prueba**:
  * **Email**: `diego.pardo@universidad.edu`
  * **Password**: `password123`
* **Administrador de Prueba**:
  * **Email**: `admin@universidad.edu`
  * **Password**: `password123`

