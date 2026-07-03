import 'dart:math';
import 'package:hectarea/coordenada.dart';

class CalculoService {
  static const double _radioTierraMetros = 6371000;

  /// Distancia entre dos coordenadas usando la fórmula de Haversine.
  /// Retorna la distancia en metros.
  double haversine(Coordenada a, Coordenada b) {
    final double lat1Rad = _gradosARadianes(a.latitud);
    final double lat2Rad = _gradosARadianes(b.latitud);
    final double deltaLat = _gradosARadianes(b.latitud - a.latitud);
    final double deltaLon = _gradosARadianes(b.longitud - a.longitud);

    final double formula =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);

    final double c = 2 * atan2(sqrt(formula), sqrt(1 - formula));

    return _radioTierraMetros * c;
  }

  /// Distancia total de un trayecto (suma de segmentos consecutivos).
  double distanciaTotal(List<Coordenada> puntos) {
    if (puntos.length < 2) return 0;

    double total = 0;
    for (int i = 0; i < puntos.length - 1; i++) {
      total += haversine(puntos[i], puntos[i + 1]);
    }
    return total;
  }

  /// Área de un polígono cerrado usando la fórmula Shoelace (Braden, 1986),
  /// adaptada a coordenadas geográficas mediante una proyección local plana.
  /// Retorna el área en metros cuadrados.
  double shoelace(List<Coordenada> puntos) {
    if (puntos.length < 3) {
      throw ArgumentError(
        'Se necesitan al menos 3 puntos para calcular un área.',
      );
    }

    // Proyección local: convierte lat/lon a metros usando el primer punto
    // como origen. Válido para superficies pequeñas (fincas, lotes), que es
    // el rango de uso definido en la propuesta (500 m² a 5 hectáreas).
    final double latOrigen = _gradosARadianes(puntos.first.latitud);
    final List<Point<double>> puntosMetros = puntos.map((c) {
      final double x =
          _gradosARadianes(c.longitud) * _radioTierraMetros * cos(latOrigen);
      final double y = _gradosARadianes(c.latitud) * _radioTierraMetros;
      return Point(x, y);
    }).toList();

    double suma = 0;
    for (int i = 0; i < puntosMetros.length; i++) {
      final Point<double> actual = puntosMetros[i];
      final Point<double> siguiente =
          puntosMetros[(i + 1) % puntosMetros.length];
      suma += (actual.x * siguiente.y) - (siguiente.x * actual.y);
    }

    return suma.abs() / 2;
  }

  double _gradosARadianes(double grados) => grados * pi / 180;
}
