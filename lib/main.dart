import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pompadour',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> vehicles = [];

  @override
  void initState() {
    super.initState();
    vehicles = [
      Container(
        color: Colors.blue,
        width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        width: 100,
        height: 100,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFEFEFBB), Color(0xFFD4D3DD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "mobfare",
                  style: TextStyle(fontSize: 35),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 20,
                      children: [
                        FeaturedVehicles(Vehicle('mini_bus', "Mini Bus",
                            '/assets/images/mini-bus.png')),
                        FeaturedVehicles(Vehicle('mini_bus', "Mini Bus",
                            '/assets/images/mini-bus.png')),
                        FeaturedVehicles(Vehicle('mini_bus', "Mini Bus",
                            '/assets/images/mini-bus.png')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget FeaturedVehicles(Vehicle vhc) {
    final TextEditingController _fromController = TextEditingController();
    final TextEditingController _toController = TextEditingController();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            List<String> cities = ['Carmen', 'Foo', 'Bar', 'Baz'];
            return AlertDialog(
              title: Text(vhc.name),
              content: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    TypeAheadField(
                      controller: _fromController,
                      suggestionsCallback: (pattern) => cities
                          .where((element) => element
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList(),
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (value) {
                        _fromController.text = value;
                      },
                    ),
                    TypeAheadField(
                      controller: _toController,
                      suggestionsCallback: (pattern) => cities
                          .where((element) => element
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList(),
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (value) {
                        _toController.text = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _fromController.text = '';

                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                )
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0x80FFFFFF),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 180,
              width: double.infinity,
              child: Placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(vhc.name),
            ),
          ],
        ),
      ),
    );
  }
}

class Vehicle {
  String id;
  String name;
  String image;
  Vehicle(this.id, this.name, this.image);
}
