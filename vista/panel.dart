import 'package:apk_mapa/controlador/utiles/mensajeUtil.dart';
import 'package:flutter/material.dart';

class Panel extends StatefulWidget {
  const Panel({super.key});

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  final List<String> _lugares = [
    'Iglesia',
    'Hotel',
    'Farmacia',
    'Restaurante',
    'Universidad',
    'Parque',
    'Estadio',
    'Museo',
    'Teatro',
    'Cine',
    'Centro comercial',
    'Banco',
    'Hospital',
  ]; //lista de lugares
  String? _lugarSeleccionado;

  void _buscarLugares() {
    //si la busqueda no esta vacia
    if (_lugarSeleccionado != null) {
      // se redirige a la vista de mapa con el lugar seleccionado
      Navigator.pushNamed(context, '/mapa', arguments: _lugarSeleccionado);
    } else {
      //mensaje de error
      MensajeUtil.mensajeError("Seleccione un lugar", context);
    }
  }

  @override
  //metodo para construir la vista de panel
  Widget build(BuildContext context) {
    //se retorna un Scaffold
    return Scaffold(
        //se le da un appbar
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.exit_to_app,
                color: Colors.red, size: 40, semanticLabel: 'Cerrar sesión'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: const Color.fromARGB(255, 21, 24, 28),
          title: const Text('LUGARES',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white, size: 40),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        //se le da un cuerpo
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // se crea un campo de texto para la busqueda
              const Text('Buscar lugares por categoría: ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const Padding(padding: EdgeInsets.only(top: 10)),
              DropdownButton<String>(
                  dropdownColor: const Color.fromARGB(255, 50, 50, 50),
                  hint: const Text('Seleccione un lugar',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  value: _lugarSeleccionado,
                  // cambiar el valor seleccionado
                  onChanged: (String? valor) {
                    setState(() {
                      _lugarSeleccionado = valor;
                    });
                  },
                  // se muestra la lista de lugares en el campo de texto
                  items: _lugares.map<DropdownMenuItem<String>>((String valor) {
                    return DropdownMenuItem<String>(
                      value: valor,
                      child: Text(valor,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _buscarLugares,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 70, 88, 81),
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                child: const Text('Buscar lugar',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ));
  }
}
