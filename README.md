# 📺 LabControl - Tablero Informativo / App de Smart TV

**LabControl Smart TV** es el módulo de tablero informativo de la solución integral **LabControl** (sistema para la gestión de préstamos de equipo tecnológico en laboratorios universitarios). 

Esta aplicación está desarrollada en **Flutter** para dispositivos Android TV / Smart TV. Su objetivo es actuar como un monitor en tiempo real dentro del laboratorio, exponiendo la disponibilidad del stock, las alertas de préstamos vencidos y las métricas generales de uso.

---

## 🛠️ Tecnologías y Arquitectura

* **Frontend**: Flutter (Android TV / Android SDK).
* **Base de Datos**: PostgreSQL 15 (ejecutada mediante Docker).
* **Servidor Backend**: REST API en Node.js (Express).
* **Control y Navegación**: Diseñado específicamente para interacción mediante control remoto (D-Pad / Teclas de Dirección).

---

## 📋 Características Principales

1. **Catálogo de Equipos y Stock (Monitoreo en tiempo real):**
   * Grilla interactiva con fotos del producto, código único del equipo, ubicación física en el laboratorio y stock actual (ej. *2 / 8 Libres*).
   * Tarjetas con indicadores visuales de estado (*Disponible, Stock Bajo, Agotado*) y foco D-Pad con escalado y resplandor verde.
2. **Pedidos y Turnos:**
   * Tabla dinámica de préstamos activos en tiempo real con datos de Alumno, Matrícula, Equipo prestado, Fecha de devolución y Estado.
   * Panel de **Equipos Vencidos** (alertas críticas coloreadas con temporizador de retraso).
   * Lista de **Actividad Reciente** (historial de reservó, recogió, devolvió o canceló en tiempo real).
3. **Resumen del Lab:**
   * Anillo gráfico dinámico con porcentaje de disponibilidad global.
   * Métricas detalladas por categorías (*Electrónica, Cómputo, Redes y Otros*).

---

## 🚀 Comandos Básicos y Despliegue

### 1. Levantar la Base de Datos (PostgreSQL en Docker)
Accede a la carpeta del backend y ejecuta el contenedor de Docker en segundo plano (puerto `5433` mapeado):
```bash
cd lab_control_backend
docker-compose up -d
```

### 2. Iniciar el Backend (Node.js REST API)
Instala las dependencias de Node.js e inicia el servidor en el puerto `8080` (en modo desarrollo):
```bash
cd lab_control_backend
npm install
npm run dev
```

### 3. Ejecutar la Aplicación de Smart TV (Flutter)
Asegúrate de tener un emulador de Android TV o dispositivo conectado. Desde la raíz del proyecto de TV, ejecuta:
```bash
# Ver dispositivos conectados
flutter devices

# Ejecutar la aplicación en modo Debug
flutter run

# Ejecutar especificando el emulador de TV
flutter run -d emulator-5554
```

---

## 🕹️ Controladores y Simulación (TV Emulator)

Para interactuar con la interfaz en el emulador de Smart TV desde tu computadora:
* **Flechas de Dirección / D-Pad (Up, Down, Left, Right)**: Para navegar entre las tarjetas de inventario y menús.
* **Enter / Space**: Para seleccionar un equipo y abrir el modal con el detalle completo del producto.
* **`r` (en la terminal de Flutter)**: Para realizar un Hot Reload (recarga rápida de cambios).
* **`R` (en la terminal de Flutter)**: Para realizar un Hot Restart (reinicio completo de la aplicación).
