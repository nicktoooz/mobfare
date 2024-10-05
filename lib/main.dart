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
      FeaturedVehicles(Vehicle(
        'tricycle',
        "Tricycle",
        'assets/image/tricycle.png',
      )),
      FeaturedVehicles(
        Vehicle('bus', "Bus", 'assets/image/bus.png'),
      ),
      FeaturedVehicles(
        Vehicle('jeepney', "Jeepney", 'assets/image/jeepney.png'),
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

  Widget FeaturedVehicles(
    Vehicle vhc,
  ) {
    final TextEditingController _fromController = TextEditingController();
    final TextEditingController _toController = TextEditingController();
    int payment = 0;
    String change = '';
    String choices = 'regular';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            List<String> cities = ['Urdaneta', 'Dagupan', 'Calasiao'];
            String fareResult = '';
            void changeBackgroundColour(StateSetter updateState, String _type) {
              updateState(
                () {
                  choices = _type;
                },
              );
            }

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
                    if (payment > 0 && (payment - adjustedFare) > 0) {
                      change = 'Change: ${(payment - adjustedFare)}';
                    } else {
                      change = 'Insufficient payment';
                    }
                    ;
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
                    height: 350,
                    child: Column(
                      children: [
                        TypeAheadField(
                          builder: (context, controller, focusNode) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: "Origin",
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
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
                          builder: (context, controller, focusNode) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: "Destination",
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                          controller: _toController,
                          suggestionsCallback: (pattern) {
                            computeFare(setStateDialog, choices);
                            return cities
                                .where((city) => city
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
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            onChanged: (val) {
                              payment = int.parse(val);
                              computeFare(setStateDialog, choices);
                            },
                            decoration: const InputDecoration(
                              hintText: "Payment",
                              border: OutlineInputBorder(),
                            )),
                        const SizedBox(height: 20),
                        Text(
                          fareResult,
                          style: TextStyle(
                            color: fareResult.contains('not available')
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          change,
                          style: TextStyle(
                            color: fareResult.contains('not available')
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  choices = 'regular';
                                  changeBackgroundColour(
                                      setStateDialog, 'regular');
                                  computeFare(setStateDialog, choices);
                                },
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                      ),
                                      color: choices == 'regular'
                                          ? Colors.blue.shade100
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8)),
                                  width: 50,
                                  child: Center(
                                    child:
                                        Image.asset('assets/image/regular.png'),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  choices = 'student';
                                  changeBackgroundColour(setStateDialog, 'pwd');
                                  computeFare(setStateDialog, choices);
                                },
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                      ),
                                      color: choices == 'pwd'
                                          ? Colors.blue.shade100
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8)),
                                  width: 50,
                                  child: Center(
                                    child: Image.asset('assets/image/pwd.png'),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  choices = 'pwd';
                                  changeBackgroundColour(
                                      setStateDialog, 'student');
                                  computeFare(setStateDialog, choices);
                                },
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                      ),
                                      color: choices == 'student'
                                          ? Colors.blue.shade100
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8)),
                                  width: 50,
                                  child: Center(
                                    child:
                                        Image.asset('assets/image/student.png'),
                                  ),
                                ),
                              ),
                            ],
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
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.asset(vhc.image),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                vhc.name,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
