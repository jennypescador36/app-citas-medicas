# Despliegue en la nube y generación de apps móviles

Proyecto: **App Citas Médicas** – HU001 Registro de usuario y HU010 Mis Citas.

| Parte | Tecnología | Dónde corre |
|---|---|---|
| Backend | Quarkus 3 (Java 21) + PostgreSQL | Render (Docker) |
| Frontend | Flutter (`frontend_registro/`) | APK Android / IPA iOS |
| CI | GitHub Actions (`.github/workflows/build-apps.yml`) | GitHub |

## 1. Backend en Render (una sola vez)

1. Entrar a <https://dashboard.render.com> con la cuenta de GitHub.
2. **New → Blueprint** y seleccionar el repositorio `app-citas-medicas`.
3. Render lee `render.yaml` y crea:
   - `citas-db`: PostgreSQL gratuito (base `bd_proyecto_salud`).
   - `app-citas-backend`: servicio web que compila el `Dockerfile`.
4. Pulsar **Apply** y esperar a que el servicio quede en estado *Live* (el primer build tarda de 5 a 10 minutos).
5. Probar en el navegador:
   - `https://app-citas-backend.onrender.com/hello` → `Hello RESTEasy`
   - `https://app-citas-backend.onrender.com/api/usuarios` → `[]`

Las tablas `usuario` y `citas` se crean solas (`quarkus.hibernate-orm.database.generation=update`).

> En el plan gratuito el servicio se duerme tras 15 minutos sin uso; la primera petición después de eso tarda unos 50 segundos.
> La base PostgreSQL gratuita de Render vence a los 30 días.

**Si Render asigna otra URL** (porque el nombre ya estaba ocupado), cópiela y en GitHub vaya a
*Settings → Secrets and variables → Actions → Variables* y cree `API_URL` con esa URL. Luego vuelva a ejecutar el workflow.

### Endpoints

| HU | Método | Ruta | Descripción |
|---|---|---|---|
| HU001 | POST | `/api/usuarios/registro` | Registro de usuario |
| HU001 | GET | `/api/usuarios` | Lista de usuarios (sin contraseña) |
| HU002 | POST | `/api/usuarios/login` | Inicio de sesión `{correo, contrasena}` |
| HU006 | GET | `/api/especialidades` | Especialidades activas |
| HU006 | GET | `/api/especialidades/{id}/profesionales` | Profesionales y próxima disponibilidad |
| HU006 | GET | `/api/profesionales/{id}/disponibilidad` | Fechas y horas libres (14 días) |
| HU008 | POST | `/api/citas/agendar` | Agendar `{idUsuario, idProfesional, fecha, hora}` |
| HU010 | GET | `/api/citas/usuario/{idUsuario}` | Citas del paciente |
| HU012 | PUT | `/api/citas/{id}/reprogramar` | Reprogramar `{idUsuario, fecha, hora}` |

Al arrancar por primera vez, el backend carga especialidades y profesionales de ejemplo
(`DatosIniciales.java`) si la tabla `especialidad` está vacía.

### Tablas en PostgreSQL

| Tabla | HU | Contenido |
|---|---|---|
| `usuario` | HU001, HU002 | Pacientes y profesionales registrados (`activo`, `tipo_usuario`) |
| `especialidad` | HU006 | Especialidades médicas |
| `profesional` | HU006 | Médicos, horario y días de atención |
| `citas` | HU008, HU010, HU012 | Citas (`id_profesional`, `fecha_inicio`, `estado`) |

## Ramas en GitHub

| Rama | Uso |
|---|---|
| `master` | Versión estable entregada |
| `develop` | Integración de las HU terminadas |
| `HU001`, `HU002`, `HU006`, `HU008`, `HU010`, `HU012` | Desarrollo de cada historia de usuario |
| `main` | Rama que despliega Render (igual a `master`) |

Flujo: cada HU se desarrolla en su rama → merge a `develop` → `develop` se integra en `master`.

## 2. APK Android e IPA iOS (automático)

Cada `git push` a `main` ejecuta el workflow **Build backend y apps moviles**:

- **Backend Quarkus**: compila con Maven para detectar errores antes de que Render despliegue.
- **APK Android**: `flutter build apk --release` apuntando a la URL de Render.
- **iOS (sin firmar)**: `flutter build ios --no-codesign` en macOS y lo empaqueta como `.ipa`.

Para descargarlos: GitHub → pestaña **Actions** → la ejecución más reciente → sección **Artifacts**:
`citas-medicas-android-apk` y `citas-medicas-ios-ipa`.

### Instalar en Android
Copiar `app-release.apk` al teléfono, abrirlo y permitir *instalar apps de origen desconocido*.

### Instalar en iOS
Apple no permite instalar una app sin firma. Opciones con el `.ipa` sin firmar:
- **Sideloadly** o **AltStore** desde Windows con un Apple ID gratuito (la app dura 7 días).
- Con cuenta de Apple Developer (USD 99/año): firmar y distribuir por TestFlight.
- En una Mac: `flutter run --release` con el iPhone conectado.

## 3. Compilar el APK en local (Windows)

```bash
cd frontend_registro
flutter build apk --release --dart-define=API_URL=https://app-citas-backend.onrender.com
```

Resultado: `frontend_registro/build/app/outputs/flutter-apk/app-release.apk`.
Sin `--dart-define` la app usa el backend local (`http://10.0.2.2:8080` en el emulador).

Requisitos: JDK 17 y Android NDK `28.2.13676358` (`android sdk install "ndk;28.2.13676358"`).
Si Gradle muestra `Unable to establish loopback connection`, use una carpeta temporal sin espacios ni nombre corto:

```powershell
$env:TMP="C:\gtmp"; $env:TEMP="C:\gtmp"; $env:JAVA_TOOL_OPTIONS="-Djdk.net.unixdomain.tmpdir=C:\gtmp"
```

## 4. Backend en local

```bash
./mvnw quarkus:dev
```
Usa PostgreSQL local (`localhost:5432/bd_proyecto_salud`, usuario `postgres`). Se puede cambiar con `DB_URL`, `DB_USER` y `DB_PASSWORD`.
