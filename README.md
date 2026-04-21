# Eye Alert — detector de somnolencia

Aplicación Flutter (Android/iOS/…) que analiza la cámara frontal con **Google ML Kit**, muestra alertas (audio + vibración), registra **sesiones de conducción** y **uso diario** en **Supabase**, y ofrece mapa y estadísticas.

## Requisitos en Supabase

Ejecuta el SQL de `supabase/migrations/001_eye_alert_schema.sql` en el editor SQL del proyecto para crear:

- `app_daily_usage` — aperturas por día por usuario  
- `driving_sessions` — resumen por ruta (tiempos por nivel, máximo alcanzado, eventos críticos)  
- `drowsiness_samples` — muestras periódicas durante la ruta  
- `events` — alertas críticas con GPS (con `user_id`)

Ajusta políticas RLS si ya tenías tablas con otro esquema.

## Internacionalización

Textos en `l10n/app_en.arb` y `l10n/app_es.arb`. Tras cambiar ARB:

```bash
flutter gen-l10n
```

La salida queda en `lib/l10n/` (ver `l10n.yaml`).

## Sonido de alarma

Incluido `assets/sounds/alarm.wav`. Si cambias el archivo, mantén la ruta en `pubspec.yaml`.

## Configuración local

Las claves de Supabase están en `lib/core/env.dart` para desarrollo; en producción conviene `--dart-define` o variables de entorno no versionadas.
