# Guía para Publicar MisCoches en la App Store

## 1. Preparación Inicial

### 1.1 Crear una cuenta de Apple Developer
- Ve a https://developer.apple.com
- Inscríbete en el Apple Developer Program ($99/año)
- Espera la confirmación (puede tomar 24-48 horas)

### 1.2 Cambiar el Bundle Identifier
El bundle identifier debe ser único. Abre el proyecto en Xcode:

```bash
open ios/Runner.xcworkspace
```

En Xcode:
1. Selecciona "Runner" en el navegador de proyectos
2. Ve a la pestaña "Signing & Capabilities"
3. Cambia el Bundle Identifier de `com.example.miscoches` a algo como:
   - `com.tunombre.miscoches`
   - O usa tu dominio: `com.tudominio.miscoches`

### 1.3 Configurar el Team de Desarrollo
En la misma pestaña "Signing & Capabilities":
1. Desmarca "Automatically manage signing" temporalmente
2. Selecciona tu Team de Apple Developer
3. Vuelve a marcar "Automatically manage signing"

## 2. Crear el Icono de la App

Necesitas un icono de 1024x1024 píxeles. Puedes usar estas herramientas:
- https://appicon.co (generador online)
- https://www.canva.com (diseño)

El icono debe:
- Ser cuadrado (1024x1024px)
- NO tener transparencia
- NO tener esquinas redondeadas (iOS las agrega automáticamente)
- Formato PNG

Guarda el icono generado en: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 3. Crear la App en App Store Connect

1. Ve a https://appstoreconnect.apple.com
2. Haz clic en "Mis Apps"
3. Clic en el botón "+"
4. Selecciona "Nueva App"
5. Completa:
   - **Plataforma**: iOS
   - **Nombre**: MisCoches
   - **Idioma principal**: Español
   - **Bundle ID**: Selecciona el que configuraste (com.tunombre.miscoches)
   - **SKU**: miscoches-app (puede ser cualquier identificador único)
   - **Acceso de usuario**: Acceso completo

## 4. Compilar para Release

### 4.1 Limpiar el proyecto
```bash
flutter clean
flutter pub get
```

### 4.2 Crear el build de iOS
```bash
flutter build ipa --release
```

Este comando generará el archivo .ipa en:
`build/ios/archive/Runner.xcarchive`

## 5. Subir a App Store Connect

### Opción A: Usar Xcode (Recomendado)
```bash
open build/ios/archive/Runner.xcarchive
```

En Xcode:
1. Se abrirá el "Organizer"
2. Selecciona tu build
3. Clic en "Distribute App"
4. Selecciona "App Store Connect"
5. Clic en "Upload"
6. Sigue los pasos del asistente

### Opción B: Usar Transporter
1. Descarga "Transporter" de la Mac App Store
2. Abre Transporter
3. Arrastra el archivo .ipa
4. Clic en "Deliver"

## 6. Configurar la Información en App Store Connect

Vuelve a https://appstoreconnect.apple.com y completa:

### 6.1 Información de la App
- **Subtítulo** (30 caracteres): "Gestiona tus coches fácilmente"
- **Descripción**: 
```
MisCoches es la aplicación perfecta para gestionar toda la información de tus vehículos en un solo lugar.

CARACTERÍSTICAS PRINCIPALES:
• Gestión de múltiples coches con galería de fotos
• Registro de mantenimientos y recordatorios
• Control de repostajes y consumo
• Seguimiento de gastos y cuotas mensuales
• Localización de estacionamiento con GPS
• Lista de lugares frecuentes
• Tareas y recordatorios personalizados
• Notas e ideas de mejoras
• KPIs de uso (km/mes, km/año)
• Modo oscuro
• Coches deseados (wishlist)

PERFECTO PARA:
• Propietarios de uno o varios vehículos
• Control de gastos de financiamiento
• Seguimiento de kilometraje
• Historial completo de mantenimiento
• Gestión de flota personal

¡Descarga MisCoches y mantén todos tus coches perfectamente organizados!
```

- **Palabras clave**: coches,autos,vehiculos,mantenimiento,gasolina,taller,gestion,gastos
- **URL de soporte**: (tu página web o email de soporte)
- **URL de marketing**: (opcional)

### 6.2 Categorías
- **Categoría principal**: Productividad
- **Categoría secundaria**: Finanzas

### 6.3 Información de privacidad
- **URL de la política de privacidad**: (necesitarás crear una)
- Declara que la app:
  - Recopila fotos (para galería de coches)
  - Recopila ubicación (para estacionamiento)
  - Los datos se almacenan localmente (SQLite)
  - NO se comparten datos con terceros

### 6.4 Calificación por edades
Responde el cuestionario. La app debería ser 4+ (para todos)

### 6.5 Capturas de pantalla
Necesitas capturas de:
- iPhone 6.9" (iPhone 17 Pro Max): Al menos 3 capturas
- iPhone 6.5": Al menos 3 capturas
- iPad Pro 13": Al menos 3 capturas

Toma capturas mostrando:
1. Lista de coches con resumen financiero
2. Detalle de un coche con tabs
3. Formulario de mantenimiento o repostaje
4. Vista de lugares o estacionamiento
5. KPIs y estadísticas

### 6.6 Información de compilación
Una vez subido el .ipa (paso 5), aparecerá en la sección de "Compilación"
1. Selecciona la compilación
2. Agrega información sobre la exportación de cifrado (selecciona "NO")

## 7. Enviar a Revisión

1. Completa toda la información requerida
2. Guarda los cambios
3. Clic en "Agregar para revisión"
4. Clic en "Enviar para revisión"

## 8. Tiempo de Revisión

- La revisión puede tomar de 24 horas a 7 días
- Recibirás notificaciones por email sobre el estado
- Si es rechazada, corrige los problemas y vuelve a enviar

## 9. Después de la Aprobación

Una vez aprobada:
- Puedes lanzarla inmediatamente o programar una fecha
- La app aparecerá en la App Store en ~24 horas
- Podrás ver las descargas en App Store Connect

## Comandos Útiles

### Ver dispositivos disponibles
```bash
flutter devices
```

### Ejecutar en simulador iPad
```bash
flutter run -d "iPad Pro 13-inch (M5)"
```

### Crear screenshots automáticamente
Instala el paquete:
```bash
flutter pub add dev:screenshots
```

### Verificar que todo está correcto antes de subir
```bash
flutter analyze
flutter test
```

### Actualizar versión para nueva release
Edita `pubspec.yaml`:
```yaml
version: 1.0.1+2  # 1.0.1 es la versión, +2 es el build number
```

## Checklist Final Antes de Subir

- [ ] Bundle ID único configurado
- [ ] Icono de 1024x1024px listo
- [ ] Permisos (cámara, galería, ubicación) con descripciones en español
- [ ] Versión correcta en pubspec.yaml
- [ ] App probada en iPhone y iPad
- [ ] Capturas de pantalla tomadas
- [ ] Descripción y keywords preparadas
- [ ] Política de privacidad lista
- [ ] Email de soporte configurado
- [ ] Build compilado sin errores
- [ ] Subido a App Store Connect
- [ ] Información completada en App Store Connect

## Soporte

Si necesitas ayuda:
- Documentación oficial: https://docs.flutter.dev/deployment/ios
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Foros de Apple Developer: https://developer.apple.com/forums/

¡Buena suerte con la publicación! 🚀
