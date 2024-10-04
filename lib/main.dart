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

  final Map<String, Map<String, int>> baseFareData = {
    'Urdaneta': {'Dagupan': 58, 'Calasiao': 40},
    'Dagupan': {'Urdaneta': 58, 'Calasiao': 20},
    'Calasiao': {'Dagupan': 20, 'Urdaneta': 40},
  };

  @override
  void initState() {
    super.initState();
    vehicles = [
      FeaturedVehicles(
          Vehicle('tricycle', "Tricycle", '/assets/images/tricycle.png')),
      FeaturedVehicles(Vehicle('bus', "Bus", '/assets/images/bus.png')),
      FeaturedVehicles(
          Vehicle('jeepney', "Jeepney", '/assets/images/jeepney.png')),
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
              end: Alignment.bottomCenter,
            ),
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
                      children: vehicles,
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
    String choices = 'regular';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            List<String> cities = ['Urdaneta', 'Dagupan', 'Calasiao'];
            String fareResult = 'FOOO';

            void computeFare(StateSetter updateState, String type) {
              String fromCity = _fromController.text;
              String toCity = _toController.text;

              if (fromCity.isNotEmpty && toCity.isNotEmpty) {
                int? baseFare = calculateBaseFare(fromCity, toCity);

                if ((type == 'student' || type == 'pwd') && baseFare != null) {
                  baseFare = (baseFare * 0.8).round();
                }

                if (baseFare != null) {
                  int adjustedFare = adjustFareByVehicle(baseFare, vhc.id);
                  updateState(() {
                    fareResult =
                        '${choices.replaceFirst(choices[0], choices[0].toUpperCase())}: $fromCity -> $toCity : ₱$adjustedFare';
                  });
                } else {
                  updateState(() {
                    fareResult =
                        'Fare information not available for the selected route.';
                  });
                }
              }
            }

            return AlertDialog(
              title: Text(vhc.name),
              content: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return SizedBox(
                    height: 250,
                    child: Column(
                      children: [
                        TypeAheadField(
                          controller: _fromController,
                          suggestionsCallback: (pattern) {
                            computeFare(setStateDialog, choices);
                            return cities
                                .where((element) => element
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSelected: (value) {
                            _fromController.text = value;
                            computeFare(setStateDialog, choices);
                          },
                        ),
                        const SizedBox(height: 10),
                        TypeAheadField(
                          controller: _toController,
                          suggestionsCallback: (pattern) {
                            computeFare(setStateDialog, choices);
                            return cities
                                .where((element) => element
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSelected: (value) {
                            _toController.text = value;
                            computeFare(setStateDialog, choices);
                          },
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  choices = 'regular';
                                  computeFare(setStateDialog, choices);
                                },
                                child: Container(
                                    color: Colors.blue, height: 50, width: 50),
                              ),
                              GestureDetector(
                                onTap: () {
                                  choices = 'student';
                                  computeFare(setStateDialog, choices);
                                },
                                child: Container(
                                    color: Colors.blue, height: 50, width: 50),
                              ),
                              GestureDetector(
                                onTap: () {
                                  choices = 'pwd';
                                  computeFare(setStateDialog, choices);
                                },
                                child: Container(
                                    color: Colors.blue, height: 50, width: 50),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          fareResult,
                          style: TextStyle(
                            color: fareResult.contains('not available')
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _fromController.text = '';
                    _toController.text = '';
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
          borderRadius: BorderRadius.circular(12),
        ),
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

  // Base fare calculation function
  int? calculateBaseFare(String from, String to) {
    if (baseFareData.containsKey(from) && baseFareData[from]!.containsKey(to)) {
      return baseFareData[from]![to];
    }
    return null;
  }

  int adjustFareByVehicle(int baseFare, String vehicleType) {
    switch (vehicleType) {
      case 'tricycle':
        return (baseFare * 1.5).round();
      case 'jeepney':
        return baseFare;
      case 'bus':
        return (baseFare * 0.8).round();
      default:
        return baseFare;
    }
  }
}

class Vehicle {
  String id;
  String name;
  String image;
  Vehicle(this.id, this.name, this.image);
}
