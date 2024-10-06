import 'package:apk_mapa/vista/mapa.dart';
import 'package:apk_mapa/vista/panel.dart';
import 'package:apk_mapa/vista/sesionVista.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio de sesion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SesionVista(),
      //rutas
      routes: {
        '/panel': (context) => const Panel(),
        '/mapa': (context) => const MapaVista(),
      },
    );
  }
}
