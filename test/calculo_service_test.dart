// IMPORTANTE: cambia 'hectarea' por el nombre real que aparece en el campo
// "name:" de tu pubspec.yaml, si es distinto.
import 'package:flutter_test/flutter_test.dart';
import 'package:hectarea/calculo_service.dart';
import 'package:hectarea/coordenada.dart';

void main() {
  final calculoService = CalculoService();

  group('CalculoService - Haversine', () {
    test('distancia entre dos puntos idénticos es cero', () {
      final punto = Coordenada(
        latitud: 1.1499,
        longitud: -76.6486,
        altitud: 600,
        precision: 3,
        timestamp: DateTime.now(),
      );

      final distancia = calculoService.haversine(punto, punto);
      expect(distancia, closeTo(0, 0.01));
    });

    test('distancia aproximada entre Mocoa y Puerto Asís (~60-80 km)', () {
      final mocoa = Coordenada(
        latitud: 1.1499,
        longitud: -76.6486,
        altitud: 600,
        precision: 3,
        timestamp: DateTime.now(),
      );
      final puertoAsis = Coordenada(
        latitud: 0.5069,
        longitud: -76.5006,
        altitud: 250,
        precision: 3,
        timestamp: DateTime.now(),
      );

      final distancia = calculoService.haversine(mocoa, puertoAsis);
      // Rango razonable en línea recta, no distancia vial.
      expect(distancia, greaterThan(60000));
      expect(distancia, lessThan(80000));
    });
  });

  group('CalculoService - Shoelace', () {
    test('área aproximada de un cuadrado de ~100m x 100m', () {
      final puntos = [
        Coordenada(
          latitud: 1.1000,
          longitud: -76.6000,
          altitud: 600,
          precision: 3,
          timestamp: DateTime.now(),
        ),
        Coordenada(
          latitud: 1.1000,
          longitud: -76.5991,
          altitud: 600,
          precision: 3,
          timestamp: DateTime.now(),
        ),
        Coordenada(
          latitud: 1.1009,
          longitud: -76.5991,
          altitud: 600,
          precision: 3,
          timestamp: DateTime.now(),
        ),
        Coordenada(
          latitud: 1.1009,
          longitud: -76.6000,
          altitud: 600,
          precision: 3,
          timestamp: DateTime.now(),
        ),
      ];

      final area = calculoService.shoelace(puntos);
      // Rango amplio porque la proyección local introduce pequeña distorsión.
      expect(area, greaterThan(8000));
      expect(area, lessThan(12000));
    });

    test('lanza error con menos de 3 puntos', () {
      final puntos = [
        Coordenada(
          latitud: 1.1,
          longitud: -76.6,
          altitud: 600,
          precision: 3,
          timestamp: DateTime.now(),
        ),
        Coordenada(
          latitud: 1.2,
          longitud: -76.7,
          altitud: 600,
          precision: 3,
          timestamp: DateTime.now(),
        ),
      ];

      expect(() => calculoService.shoelace(puntos), throwsArgumentError);
    });
  });
}
