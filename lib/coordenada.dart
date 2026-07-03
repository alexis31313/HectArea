class Coordenada {
  final double latitud;
  final double longitud;
  final double altitud;
  final double precision; // metros (accuracy reportada por el GPS)
  final DateTime timestamp;

  Coordenada({
    required this.latitud,
    required this.longitud,
    required this.altitud,
    required this.precision,
    required this.timestamp,
  });

  @override
  String toString() =>
      'Coordenada(lat: $latitud, lon: $longitud, alt: $altitud, precision: ${precision}m)';
}
