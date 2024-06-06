import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:load_calc/helpers/calc_funcs.dart';
import 'package:load_calc/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  double load = 0;
  double barWeight = 0;
  double oneSideWeight = 0;
  List<double> availablePlates = [];
  Method method = Method.greedy;
  late SharedPreferences prefs;

  List<Map<String, String>> plates = [];
  TextEditingController loadInput = TextEditingController();
  bool showTable = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Load: ${load.toString()}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: loadInput,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                fillColor: Color.fromRGBO(249, 250, 251, 1),
                contentPadding: EdgeInsets.all(10),
                hintText: "Enter Load to lift",
                filled: true,
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: RadioListTile<Method>(
                    title: const Text('Heaviest First'),
                    value: Method.greedy,
                    groupValue: method,
                    onChanged: (value) => setState(() => method = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<Method>(
                    title: const Text('Equal Jumps'),
                    value: Method.robust,
                    groupValue: method,
                    onChanged: (value) => setState(() => method = value!),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                  onPressed: getLoad,
                  style: const ButtonStyle(
                    textStyle:
                        MaterialStatePropertyAll(TextStyle(fontSize: 16)),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      Color.fromRGBO(94, 74, 227, 1),
                    ),
                    minimumSize: MaterialStatePropertyAll(
                      Size(double.infinity, 45),
                    ),
                  ),
                  child: const Text("Submit")),
            ),
            if (showTable)
              const SizedBox(
                height: 10,
              ),
            if (showTable)
              DataTable(
                  columns: const [
                    DataColumn(label: Text("Set")),
                    DataColumn(label: Text("Plates")),
                    DataColumn(label: Text("Progression")),
                  ],
                  rows: plates
                      .map(
                        (platesToLoad) => DataRow(cells: [
                          DataCell(Text(platesToLoad['set']!)),
                          DataCell(Text(platesToLoad['plate']!)),
                          DataCell(Text(platesToLoad['progression']!)),
                        ]),
                      )
                      .toList())
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    loadInput.dispose();
    super.dispose();
  }

  void getLoad() {
    setState(() {
      List<double> platesToLoad;
      load = double.parse(loadInput.text);
      plates = getPlates(oneSideWeight, availablePlates, barWeight);
      if (method == Method.greedy) {
        availablePlates.sort((a, b) => b.compareTo(a));
        oneSideWeight = (load - barWeight) / 2;
        platesToLoad = greedyApproach(oneSideWeight, availablePlates);
      } else {
        platesToLoad = robustApproach(load, barWeight, availablePlates);
      }
      plates = getPlatesMapList(platesToLoad, barWeight);
      showTable = true;
    });
  }

  Future<void> getStoredWeightData() async {
    prefs = await SharedPreferences.getInstance();
    barWeight = prefs.getDouble('barWeight') ?? 0.0;

    String availablePlatesStr = prefs.getString('availablePlates') ?? "";
    if (availablePlatesStr.isNotEmpty) {
      availablePlates = jsonDecode(availablePlatesStr).cast<double>();
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getStoredWeightData();
  }
}
