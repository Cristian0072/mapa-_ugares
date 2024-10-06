import 'dart:math';

import 'package:apk_mapa/controlador/utiles/mensajeUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:permission_handler/permission_handler.dart';

class MapaVista extends StatefulWidget {
  const MapaVista({super.key});

  @override
  _MapaVistaState createState() => _MapaVistaState();
}

class _MapaVistaState extends State<MapaVista> {
  //Ubicacion por defecto
  LatLng _seleccionUbicacion = const LatLng(-4.00064661, -79.20426114);
  final List<Marker> _marcadores = [];

  @override
  void initState() {
    super.initState();
    _verificarUbicacion();
  }

// Método para verificar la ubicación y permisos
  void _verificarUbicacion() async {
    // Verificar si el servicio de ubicación está activo
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      _mostrarMensajePermiso();
      return;
    }
    // Verificar si la aplicación tiene permiso para acceder a la ubicación
    var estado = await Permission.location.status;
    // Verificar si el permiso de ubicación ha sido denegado o limitado
    if (estado.isGranted) {
      _obtenerUbicacionActual();
    } else if (estado.isDenied) {
      // Solicitar permiso de ubicación si no se ha concedido
      if (await Permission.location.request().isGranted) {
        _obtenerUbicacionActual();
      }
    } else if (estado.isPermanentlyDenied) {
      // Si el permiso de ubicación ha sido permanentemente denegado, mostrar un mensaje de advertencia
      _mostrarMensajePermiso();
    }
  }

  // Método para obtener la ubicación actual del dispositivo
  void _obtenerUbicacionActual() async {
    Position posicion = await Geolocator.getCurrentPosition();
    // se actualiza la ubicación actual
    setState(() {
      _seleccionUbicacion = LatLng(posicion.latitude, posicion.longitude);
    });
    buscarLugares();
  }

  // Método para buscar lugares cercanos dentro de un radio específico
  void buscarLugares() async {
    final String categoriaSeleccionada =
        ModalRoute.of(context)!.settings.arguments as String;
    const double radioBusqueda = 50; // Radio de búsqueda (50km)

    try {
      // Llamar a la nueva función que usa osm_nominatim
      List<Place> lugares = await buscarLugaresPorCategoria(
        categoriaSeleccionada,
        _seleccionUbicacion.latitude,
        _seleccionUbicacion.longitude,
        radioBusqueda,
      );
      // Actualizar los marcadores en el mapa con los lugares encontrados y la ubicación actual del usuario
      setState(() {
        // Limpiar marcadores
        _marcadores.clear();
        // Agregar marcador de ubicación actual
        _marcadores.add(Marker(
          width: 80.0,
          height: 80.0,
          point: _seleccionUbicacion,
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.red,
            size: 40,
          ),
        ));
        // Agregar marcadores de lugares encontrados
        for (var lugar in lugares) {
          _marcadores.add(Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lugar.lat, lugar.lon),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ));
        }
      });
    } catch (e) {
      //mensaje de error
      MensajeUtil.mensajeError(
          "Error al buscar $categoriaSeleccionada", context);
      print(e);
    }
  }

  // método para buscar lugares por categoría usando osm_nominatim
  Future<List<Place>> buscarLugaresPorCategoria(
      String categoria, double latitud, double longitud, double radio) async {
    // Calcular los limites del radio de búsqueda en grados 111.32 km = 1 grado de latitud
    double minLat = latitud - (radio / 111.32);
    double maxLat = latitud + (radio / 111.32);
    double minLon = longitud - (radio / (111.32 * cos(latitud * pi / 180)));
    double maxLon = longitud + (radio / (111.32 * cos(latitud * pi / 180)));

    return await Nominatim.searchByName(
      query: categoria, limit: 50, // Limitar la cantidad de resultados
      viewBox: ViewBox(maxLat, minLat, maxLon,
          minLon), // Usar el cuadro delimitador para buscar lugares cercanos a la ubicación actual
    );
  }

  // Método para mostrar un mensaje de advertencia cuando el permiso de ubicación ha sido denegado
  void _mostrarMensajePermiso() {
    if (!mounted) {
      return; // Verificar si el widget está montado para mostrar el diálogo
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // No se puede cerrar el diálogo haciendo clic fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Ubicación desactivada",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Activa la ubicación para continuar",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 21, 24, 28),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 60, 73, 68),
                textStyle: const TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                var estado = await Permission.location.request();
                if (estado.isGranted) {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  _obtenerUbicacionActual();
                }
              },
              child: const Text(
                "Activar ubicación",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        title: const Text('Mapa de Lugares',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white, size: 40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 40),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        child: FlutterMap(
          options:
              MapOptions(initialCenter: _seleccionUbicacion, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: _marcadores,
            ),
          ],
        ),
      ),
    );
  }
}
