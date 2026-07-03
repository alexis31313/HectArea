import 'package:geolocator/geolocator.dart';
import 'package:hectarea/coordenada.dart';

class GpsService {
  /// Verifica que el GPS esté activo y que los permisos estén concedidos.
  /// Retorna true si se puede usar el GPS, false en caso contrario.
  Future<bool> solicitarPermisos() async {
    final bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      return false;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return false;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtiene una única lectura de posición con la mejor precisión posible.
  Future<Coordenada> obtenerPosicionActual() async {
    final Position posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    return _posicionACoordenada(posicion);
  }

  /// Stream continuo de posiciones, útil para registrar el recorrido
  /// mientras el usuario camina el perímetro de un terreno.
  Stream<Coordenada> streamPosiciones({int distanciaMinimaMetros = 1}) {
    final LocationSettings ajustes = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: distanciaMinimaMetros,
    );

    return Geolocator.getPositionStream(
      locationSettings: ajustes,
    ).map(_posicionACoordenada);
  }

  /// Promedia varias lecturas consecutivas para reducir el ruido del GPS.
  /// Corresponde al Objetivo Específico 1 de la propuesta (filtrado y promedio
  /// de señal aplicados directamente en el dispositivo).
  Future<Coordenada> obtenerPosicionPromediada({int numeroLecturas = 5}) async {
    final List<Coordenada> lecturas = [];

    for (int i = 0; i < numeroLecturas; i++) {
      lecturas.add(await obtenerPosicionActual());
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final double latProm =
        lecturas.map((c) => c.latitud).reduce((a, b) => a + b) /
        lecturas.length;
    final double lonProm =
        lecturas.map((c) => c.longitud).reduce((a, b) => a + b) /
        lecturas.length;
    final double altProm =
        lecturas.map((c) => c.altitud).reduce((a, b) => a + b) /
        lecturas.length;
    final double precisionProm =
        lecturas.map((c) => c.precision).reduce((a, b) => a + b) /
        lecturas.length;

    return Coordenada(
      latitud: latProm,
      longitud: lonProm,
      altitud: altProm,
      precision: precisionProm,
      timestamp: DateTime.now(),
    );
  }

  Coordenada _posicionACoordenada(Position posicion) {
    return Coordenada(
      latitud: posicion.latitude,
      longitud: posicion.longitude,
      altitud: posicion.altitude,
      precision: posicion.accuracy,
      timestamp: posicion.timestamp ?? DateTime.now(),
    );
  }
}
