import 'package:flutter/material.dart';
import 'package:hectarea/coordenada.dart';
import 'package:hectarea/gps_service.dart';

class GpsTestScreen extends StatefulWidget {
  const GpsTestScreen({super.key});

  @override
  State<GpsTestScreen> createState() => _GpsTestScreenState();
}

class _GpsTestScreenState extends State<GpsTestScreen> {
  final GpsService _gpsService = GpsService();
  Coordenada? _ultimaLectura;
  bool _cargando = false;
  String? _error;

  Future<void> _capturarPosicion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final bool permisoOk = await _gpsService.solicitarPermisos();
      if (!permisoOk) {
        setState(() {
          _error = 'Permiso de ubicación denegado o GPS desactivado.';
          _cargando = false;
        });
        return;
      }

      final Coordenada posicion = await _gpsService.obtenerPosicionPromediada();
      setState(() {
        _ultimaLectura = posicion;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al obtener posición: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HectArea - Prueba GPS')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_cargando) const CircularProgressIndicator(),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_ultimaLectura != null) ...[
                Text('Latitud: ${_ultimaLectura!.latitud}'),
                Text('Longitud: ${_ultimaLectura!.longitud}'),
                Text('Altitud: ${_ultimaLectura!.altitud} m'),
                Text('Precisión: ${_ultimaLectura!.precision} m'),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando ? null : _capturarPosicion,
                child: const Text('Capturar posición GPS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
