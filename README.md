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


## Configuración de `API_URL` y prioridades de configuración

Recomendado para producción: pasar la URL en tiempo de compilación usando
`--dart-define`. Esto evita empaquetar archivos `.env` con secretos y es
fácil de integrar en CI/CD.

Prioridad que usa la aplicación para determinar `API_URL` (de mayor a menor):

- **Compile-time `--dart-define` (recomendado para producción)** — valor pasado
	con `flutter build` o `flutter run` usando `--dart-define=API_URL=...`.
- **Override en almacenamiento seguro** — valor guardado por la app en
	`StorageService` (útil para cambiar la URL en un dispositivo sin recompilar).
- **`.env` cargado con `flutter_dotenv`** — conveniencia para desarrollo local;
	el archivo debe existir y, si lo quieres empaquetar, añadirlo a `pubspec.yaml`
	bajo `assets:` (no recomendado para secretos en builds distribuidos).
- **Valor por defecto** en `AppConfig` (usado si ninguna de las anteriores está
	presente).

Ejemplos de uso con `--dart-define`:

```powershell
# ejecutar en modo debug/local con dart-define
flutter run --dart-define=API_URL=https://api.dev.example/upload

# compilar release con dart-define
flutter build apk --release --dart-define=API_URL=https://api.prod.example/upload
```

Notas importantes:

- El valor pasado con `--dart-define` queda embebido en el binario; no es
	seguro para secretos sensibles (API keys). Para claves secretas, usa un
	backend seguro o servicios de gestión de secretos.
- Mantén `.env` en `.gitignore` si lo usas en desarrollo, para no subir
	credenciales al repositorio.
