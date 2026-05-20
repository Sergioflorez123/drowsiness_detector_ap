# 🚗 EyeAlert: Sistema Inteligente de Detección de Somnolencia

¡Bienvenido a **EyeAlert**! Una aplicación móvil moderna y de alto rendimiento desarrollada en **Flutter** diseñada para salvar vidas en la carretera. Utiliza **Inteligencia Artificial local (Edge AI)** para monitorear en tiempo real la apertura de los ojos del conductor, emitiendo alarmas sonoras e incorporando un sistema integrado de auxilio asíncrono (SOS) que envía alertas automáticas con la ubicación GPS a contactos de emergencia mediante **Supabase** y **WhatsApp**.

---

## 🔑 Credenciales de Acceso para Pruebas

Para agilizar el proceso de revisión y evaluación en la exposición, puedes iniciar sesión directamente con la siguiente cuenta de pruebas precargada:

* **Correo Electrónico**: `salasflorez123@gmail.com`
* **Contraseña**: `salasflorez`

> [!NOTE]
> Esta cuenta de pruebas está vinculada a la base de datos segura en la nube de Supabase y tiene cargados datos de historial de ejemplo para visualizar mapas y estadísticas inmediatamente.

---

## 🌟 Características Principales

1. **Monitoreo Facial por IA Offline**: 
   * Detección ocular instantánea utilizando **Google ML Kit** localmente en el dispositivo. Funciona al 100% en carretera, incluso **sin acceso a internet**.
2. **Alertas SOS en Segundo Plano (Asíncronas)**:
   * Al detectar somnolencia crítica, el sistema dispara el flujo SOS (obtención del GPS y despacho de mensaje de WhatsApp) de forma asíncrona (`unawaited`). La cámara y la IA **nunca se detienen ni se congelan**.
3. **Tarjeta HUD Dinámica de Conducción**:
   * Pantalla de conducción interactiva que muestra el estado en tiempo real del envío SOS: *Buscando GPS*, *Enviando alerta*, *¡Alerta enviada a WhatsApp!*.
4. **Historial de Viajes Optimizado (Cero Lag)**:
   * Renderizado diferido (*lazy loading*) de mapas de ruta de Google Maps. Los mapas interactivos pesados solo se cargan en memoria RAM si el usuario decide expandir la sesión, erradicando por completo el lag y las caídas de rendimiento.
5. **Apariencia Premium Adaptativa**:
   * Rediseño completo en **Modo Claro** y **Modo Oscuro** que sigue las últimas pautas de diseño moderno. Interacciones fluidas, transiciones suaves y tarjetas táctiles ergonómicas en todo el menú de configuraciones.

---

## 🛠️ Stack Tecnológico

* **Framework principal**: [Flutter](https://flutter.dev) (Dart)
* **Gestor de Estados**: [Riverpod](https://riverpod.dev) (Arquitectura reactiva limpia)
* **Base de datos & Autenticación**: [Supabase](https://supabase.com) (PostgreSQL en la nube)
* **Procesamiento de IA**: [Google ML Kit Face Detection](https://developers.google.com/ml-kit/vision/face-detection)
* **Captura de Cámara**: [CameraX API](https://developer.android.com/training/camerax)
* **Geolocalización**: [Geolocator Plugin](https://pub.dev/packages/geolocator)
* **Mapas**: [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

---

## 🚀 Instrucciones de Configuración y Ejecución Local

### Requisitos Previos

* Tener instalado [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión 3.19.0 o superior recomendada).
* Un dispositivo físico Android/iOS conectado en modo depuración (o un emulador configurado).

### Paso 1: Clonar e instalar dependencias

Abre la terminal en la raíz del proyecto y ejecuta:

```bash
flutter pub get
```

### Paso 2: Configuración de Base de Datos (Supabase)

Si deseas configurar tu propia base de datos de Supabase, ejecuta las consultas del archivo SQL de migraciones local en el editor SQL de tu panel de Supabase:
* Ruta del esquema: `supabase/migrations/001_eye_alert_schema.sql`

Este archivo creará automáticamente la base relacional del proyecto:
* `app_daily_usage` (Contador de aperturas diarias de la app)
* `driving_sessions` (Resumen de rutas y métricas)
* `drowsiness_samples` (Muestreos periódicos del cansancio)
* `events` (Alertas críticas registradas con ubicación GPS)

> Las claves de conexión para desarrollo están preconfiguradas en `lib/core/env.dart`.

### Paso 3: Internacionalización (Multi-idioma)

La aplicación soporta Español e Inglés nativo a través de archivos de traducción ARB. Si realizas cambios en los archivos `l10n/app_es.arb` o `l10n/app_en.arb`, regenera los archivos locales ejecutando:

```bash
flutter gen-l10n
```

### Paso 4: Lanzar la aplicación

Conecta tu dispositivo de pruebas y ejecuta el comando de compilación y ejecución en modo debug:

```bash
flutter run
```

---

## 📁 Estructura del Código Fuente

* `/lib/app/`: Configuración global de rutas, paletas de colores (`eye_alert_colors.dart`) y temas del sistema.
* `/lib/core/`: Constantes globales, claves de conexión y configuraciones generales del entorno.
* `/lib/data/`: Fuentes de datos remotas y locales (Datasources) y modelos relacionales de datos.
* `/lib/presentation/`:
  * `/providers/`: Proveedores de Riverpod para manejar la lógica de estado de IA, SOS, Tema, Configuración y Ubicación de forma reactiva.
  * `/screens/`: Vistas y controladores de pantallas principales (Login, Registro, Conducción, Historial/Stats, y Ajustes).
  * `/widgets/`: Componentes modulares y reutilizables de UI (Mini-mapas, cabeceras de marca, etc.).
* `/assets/`: Sonidos de alerta de fatiga (`assets/sounds/alarm.wav`) e imágenes del logo.

---

## 📈 Autores y Licencia

Desarrollado para el proyecto de detección inteligente de fatiga en conducción.  
*Licencia MIT. El código fuente es abierto para fines formativos y expositivos.*
