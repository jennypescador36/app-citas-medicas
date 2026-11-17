# 🏥 Medical Center - App de Gestión de Citas Médicas

Aplicación multiplataforma desarrollada en **Flutter** para el registro de pacientes y la consulta de citas médicas, integrada con backend **Quarkus** y base de datos **PostgreSQL**.

---

## 🚀 Historias de Usuario Implementadas

### 📋 HU001 - Registro de Usuarios
- **Descripción:** Permite a los pacientes y personal médico registrarse en la plataforma ingresando documento, nombre completo, correo electrónico y contraseña.
- **Características UI/UX:**
  * Diseño Med-Tech moderno en tonos azul y salmón.
  * Selector intuitivo de tipo de usuario (*Paciente* vs. *Médico/Salud*).
  * Validaciones de campos en tiempo real.
  * Conexión adaptativa con el backend (aporta compatibilidad móvil `10.0.2.2` y Web/Escritorio `localhost`).

### 📅 HU010 - Consulta de Citas Médicas (`MisCitasScreen`)
- **Descripción:** Visualización adaptativa e inteligente del historial y citas programadas del paciente.
- **Características UI/UX:**
  * **Layout Responsivo Adaptativo:** Visualización en Grid de 3 columnas para Windows/Chrome y 1 columna fluida para dispositivos Android.
  * **Clasificación por Pestañas:** Separación entre *Próximas Citas* e *Histórico*.
  * **Filtros por Estado:** Chips compactos con resaltado dinámico por color (`PROGRAMADA`, `ATENDIDA`, `FINALIZADA`, `CANCELADA`).
  * **Detalle Interactivo:** Modal estilo Bottom Sheet con la información detallada del médico, código y fecha.

---

## 💻 Compatibilidad Multiplataforma
- 🤖 **Android (Emulador y Físico)**
- 💻 **Windows Desktop**
- 🌐 **Google Chrome Web Browser**

---

## 🛠️ Tecnologías Utilizadas
- **Frontend:** Flutter 3.x / Dart (Material 3 UI Layouts)
- **Backend:** Quarkus (Java / REST APIs)
- **Base de Datos:** PostgreSQL / pgAdmin

---

## 🏃 Cómo ejecutar el proyecto

1. **Clonar el repositorio y ubicarse en la rama de trabajo:**
   ```bash
   git clone [https://github.com/LisethOsorio12/RepoAppCitas.git](https://github.com/LisethOsorio12/RepoAppCitas.git)
   cd RepoAppCitas
   git checkout develop