# Tickets (mini guía de configuración)

Este repositorio contiene una app Flutter con dos pestañas: `Imagen` y `Configuración`.

La pestaña `Imagen` permite seleccionar una foto desde la galería o tomar una con la cámara, recortarla/rotarla y subirla a un endpoint configurable. La `API Key` usada para autorización se guarda de forma segura en el dispositivo usando `flutter_secure_storage`.

**Archivos importantes**
- `lib/pages/imagen_page.dart`: UI y lógica para seleccionar, recortar y subir imágenes.
- `lib/pages/configuracion_page.dart`: pantalla de configuración (placeholder).
- `lib/services/api_service.dart`: cliente para enviar la imagen al endpoint.
- `lib/services/storage_service.dart`: wrapper sobre `flutter_secure_storage` para guardar `api_key` y override de `api_url`.
- `lib/config/app_config.dart`: punto central para obtener la URL del endpoint (lee `.env` y permite override guardado).
- `.env` (no incluido en el repo): variables de entorno como `API_URL`.

**No subir secretos**
- Asegúrate de NO subir el archivo `.env` ni ninguna clave al repositorio. `.gitignore` incluye la ruta a `.env`.
- La `API Key` se guarda localmente en el dispositivo usando `flutter_secure_storage` (no en el código fuente).

Configuración rápida
1. Instala dependencias:

```powershell
flutter pub get
```

2. Crea un archivo `.env` en la raíz del proyecto (ejemplo):

```
API_URL=http://127.0.0.1/api/imagen
```

3. Ejecuta la app:

```powershell
flutter run
```

Cómo usar la funcionalidad de imagen
- Abre la pestaña `Imagen`.
- Usa `Galería` o `Cámara` para seleccionar/crear una imagen.
- Se abrirá el recortador/rotador; recorta/rota libremente.
- Pulsa `Subir imagen` para enviarla al endpoint.
- Para configurar la `API Key` (cabecera `Authorization: Bearer <key>`), pulsa `Configurar API Key (seguro)` y guarda la clave — ésta se guarda en almacenamiento seguro del dispositivo.
- Para cambiar temporalmente el endpoint desde el dispositivo, pulsa `Cambiar endpoint` y escribe la nueva URL. Esto se guarda en almacenamiento seguro y tendrá prioridad sobre `.env`.

Probar el endpoint localmente
- Si tu endpoint local está en `http://127.0.0.1`, recuerda que un emulador o dispositivo móvil no siempre accede al `localhost` de tu PC. Para probar desde un dispositivo físico puedes usar `ngrok` o exponer tu servidor.

Ejemplo con `curl` (para comprobar que tu endpoint acepta multipart POST con campo `file`):

```bash
curl -v -F "file=@/ruta/a/imagen.jpg" http://127.0.0.1/api/imagen
```

Si tu endpoint necesita autorización con `Bearer <token>`:

```bash
curl -v -H "Authorization: Bearer <API_KEY>" -F "file=@/ruta/a/imagen.jpg" http://127.0.0.1/api/imagen
```

Permisos Android / iOS
- Android: verifica que en `android/app/src/main/AndroidManifest.xml` estén los permisos de cámara y lectura/escritura si tu target lo requiere. Ejemplo mínimo:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

- iOS: agrega descripciones en `ios/Runner/Info.plist` para el uso de cámara y fotos (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`).

Notas y buenas prácticas
- Las dependencias usadas:
	- `image_picker` (selección/cámara)
	- `image_cropper` (recorte/rotación)
	- `flutter_secure_storage` (almacenamiento seguro)
	- `flutter_dotenv` (variables de entorno)
	- `http` (peticiones)
- El flujo de configuración de la URL tiene prioridad: override en `flutter_secure_storage` > `.env` (`API_URL`) > valor por defecto codificado.
- Evité dejar claves en el código; la `API Key` se almacena sólo en `flutter_secure_storage`.

Cambios futuros recomendados
- Añadir validaciones para el tamaño y tipo de archivo antes de subir.
- Implementar reintentos y manejo de errores más robusto en `ApiService`.
- Añadir tests unitarios para `ApiService` y `StorageService`.

Contacto / Próximos pasos
- Si quieres, puedo:
	- Añadir la pantalla de configuración dedicada para `API Key` y `Endpoint`.
	- Preparar permisos y manifest changes para Android/iOS (puedo aplicarlos automáticamente).
	- Integrar un mock server para pruebas locales y CI.

# tickets

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
