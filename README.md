# Mis Coches - App de Gestión de Vehículos

Aplicación Flutter para llevar el control completo de tus coches, incluyendo datos del vehículo, mantenimientos y repostajes de combustible.

## Características

### 📱 Gestión de Coches
- Agregar y editar información de tus vehículos
- Datos completos: marca, modelo, matrícula, año, color, VIN
- Control de kilometraje actualizado automáticamente
- Fecha de compra y propietario

### 🔧 Historial de Mantenimiento
- Registro completo de todos los servicios
- Tipos de mantenimiento: cambio de aceite, frenos, neumáticos, reparaciones, ITV
- Costos y talleres
- Programación de próximos mantenimientos por fecha o kilometraje
- Seguimiento de gastos totales

### ⛽ Registro de Repostajes
- Control detallado de cada repostaje
- Múltiples tipos de combustible: gasolina 95/98, diesel, eléctrico, GLP, GNC
- Cálculo automático de consumo medio (L/100km)
- Estadísticas de gastos en combustible
- Historial completo con fechas y kilometrajes

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Firebase Firestore**: Base de datos NoSQL en tiempo real
- **Firebase Auth**: Autenticación (lista para implementar)
- **Provider**: Gestión de estado
- **Material Design 3**: Diseño moderno y atractivo

## Estructura del Proyecto

```
lib/
├── models/              # Modelos de datos
│   ├── coche.dart
│   ├── mantenimiento.dart
│   └── repostaje.dart
├── screens/             # Pantallas de la aplicación
│   ├── coches_list_screen.dart
│   ├── coche_detalle_screen.dart
│   ├── coche_form_screen.dart
│   ├── mantenimiento_form_screen.dart
│   └── repostaje_form_screen.dart
├── services/            # Servicios de Firebase
│   ├── coche_service.dart
│   ├── mantenimiento_service.dart
│   └── repostaje_service.dart
├── firebase_options.dart
└── main.dart
```

## Configuración

### 1. Requisitos Previos
- Flutter SDK instalado
- Cuenta de Firebase
- Proyecto de Firebase creado

### 2. Configurar Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita Cloud Firestore en la consola de Firebase
4. Instala Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

5. Inicia sesión en Firebase:
   ```bash
   firebase login
   ```

6. Instala FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

7. Configura Firebase para tu proyecto Flutter:
   ```bash
   flutterfire configure
   ```

   Este comando:
   - Te pedirá seleccionar tu proyecto de Firebase
   - Generará automáticamente el archivo `firebase_options.dart` con tus credenciales
   - Configurará las plataformas que selecciones (iOS, Android, Web)

### 3. Instalar Dependencias

```bash
flutter pub get
```

### 4. Configurar Reglas de Firestore

En la consola de Firebase, ve a Firestore Database > Reglas y configura las reglas de seguridad:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura y escritura (para desarrollo)
    // IMPORTANTE: Cambiar estas reglas para producción
    match /{document=**} {
      allow read, write: if true;
    }
    
    // Reglas recomendadas para producción (con autenticación):
    // match /coches/{cocheId} {
    //   allow read, write: if request.auth != null;
    // }
    // match /mantenimientos/{mantenimientoId} {
    //   allow read, write: if request.auth != null;
    // }
    // match /repostajes/{repostajeId} {
    //   allow read, write: if request.auth != null;
    // }
  }
}
```

### 5. Ejecutar la Aplicación

```bash
# Para iOS
flutter run -d ios

# Para Android
flutter run -d android

# Para Web
flutter run -d chrome

# Para macOS
flutter run -d macos
```

## Uso de la Aplicación

### Agregar un Coche
1. Presiona el botón **+** en la pantalla principal
2. Completa los datos del vehículo (marca, modelo, matrícula, año son obligatorios)
3. Opcionalmente agrega color, VIN, kilometraje y propietario
4. Guarda el coche

### Registrar Mantenimiento
1. Selecciona un coche de la lista
2. Ve a la pestaña **Mantenimiento**
3. Presiona **Agregar Mantenimiento**
4. Completa los datos del servicio
5. Opcionalmente programa el próximo mantenimiento

### Registrar Repostaje
1. Selecciona un coche de la lista
2. Ve a la pestaña **Repostajes**
3. Presiona **Agregar Repostaje**
4. Ingresa litros, precio por litro y kilometraje
5. El costo total se calcula automáticamente
6. Marca "Tanque Lleno" para un cálculo preciso del consumo

## Próximas Características

- [ ] Autenticación de usuarios con Firebase Auth
- [ ] Subida de fotos de los coches
- [ ] Adjuntar documentos y facturas
- [ ] Recordatorios automáticos de mantenimiento
- [ ] Gráficos de consumo y gastos
- [ ] Exportar datos a PDF
- [ ] Modo oscuro
- [ ] Soporte para múltiples usuarios (compartir coches)

## Estructura de Base de Datos Firestore

### Colección: coches
```json
{
  "marca": "Toyota",
  "modelo": "Corolla",
  "matricula": "ABC1234",
  "año": 2020,
  "color": "Blanco",
  "vin": "JT2BF18K4X0123456",
  "kilometraje": 50000,
  "fechaCompra": "2020-01-15",
  "propietario": "Juan Pérez",
  "fechaCreacion": "timestamp",
  "fechaActualizacion": "timestamp"
}
```

### Colección: mantenimientos
```json
{
  "cocheId": "doc_id_del_coche",
  "tipo": "cambioAceite",
  "descripcion": "Cambio de aceite y filtros",
  "fecha": "2023-12-01",
  "kilometraje": 50000,
  "costo": 85.50,
  "taller": "Taller Mecánico ABC",
  "notas": "Se usó aceite sintético 5W30",
  "proximoMantenimiento": "2024-06-01",
  "proximoKilometraje": 60000,
  "fechaCreacion": "timestamp"
}
```

### Colección: repostajes
```json
{
  "cocheId": "doc_id_del_coche",
  "fecha": "2023-12-20",
  "litros": 45.5,
  "precioLitro": 1.45,
  "costoTotal": 65.98,
  "kilometraje": 52000,
  "tipoCombustible": "gasolina95",
  "tanqueLleno": true,
  "estacion": "Repsol Norte",
  "notas": "Precio especial",
  "fechaCreacion": "timestamp"
}
```

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## Soporte

Si encuentras algún problema o tienes sugerencias, por favor crea un issue en el repositorio.

---

**Desarrollado con ❤️ usando Flutter y Firebase**
