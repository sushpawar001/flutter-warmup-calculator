import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:load_calc/helpers/convert_funcs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double barWeight = 0;
  List<double> availablePlates = [];
  bool isFirstTime = false;
  String availablePlatesDisplay = '';
  late SharedPreferences prefs;
  TextEditingController barWeightInput = TextEditingController();
  TextEditingController availablePlatesInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isFirstTime
                ? const Text(
                    "Please save your settings before using the app.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  )
                : const Text(""),
            const SizedBox(height: 10),
            buildInputField(
              title: 'Bar Weight',
              controller: barWeightInput,
              onSubmit: setbarWeight,
              data: barWeight.toString(),
            ),
            const SizedBox(height: 40),
            buildInputField(
              title: 'Available Plates',
              controller: availablePlatesInput,
              onSubmit: setAvailablePlates,
              data: availablePlatesDisplay,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(
      {required String title,
      required TextEditingController controller,
      required VoidCallback onSubmit,
      String? data}) {
    return Column(
      children: [
        Text(
          data != null ? "$title: $data" : title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            fillColor: Colors.white12,
            contentPadding: const EdgeInsets.all(10),
            hintText: 'Enter $title',
            filled: true,
            prefixIcon: const Icon(Icons.fitness_center),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onSubmit,
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 16),
            ),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
              const Color.fromRGBO(94, 74, 227, 1),
            ),
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 45),
            ),
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    barWeightInput.dispose();
    availablePlatesInput.dispose();
    super.dispose();
  }

  Future<void> getStoredWeightData() async {
    prefs = await SharedPreferences.getInstance();
    barWeight = prefs.getDouble('barWeight') ?? 0.0;
    barWeightInput.text = barWeight.toString();

    String availablePlatesStr = prefs.getString('availablePlates') ?? "";
    if (availablePlatesStr.isNotEmpty) {
      availablePlates = jsonDecode(availablePlatesStr).cast<double>();
      String temp = convertDoubleToIntIfWhole(availablePlates).toString();
      temp = temp.substring(1, temp.length - 1);
      availablePlatesInput.text = temp;
      availablePlatesDisplay = temp;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getStoredWeightData();
    getFirstTimeFlag();
  }

  Future<void> setAvailablePlates() async {
    if (availablePlatesInput.text.isNotEmpty) {
      prefs = await SharedPreferences.getInstance();
      availablePlates =
          stringToDoubleList(availablePlatesInput.text).toSet().toList();
      prefs.setString('availablePlates', jsonEncode(availablePlates));
      String temp = convertDoubleToIntIfWhole(availablePlates).toString();
      temp = temp.substring(1, temp.length - 1);
      availablePlatesDisplay = temp;
    }
    setState(() {});
  }

  void getFirstTimeFlag() async {
    prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('isFirstTime') ?? true;
    prefs.setBool('isFirstTime', false);
    setState(() {});
  }

  Future<void> setbarWeight() async {
    if (barWeightInput.text.isNotEmpty) {
      barWeight = double.parse(barWeightInput.text);
      prefs = await SharedPreferences.getInstance();
      prefs.setDouble('barWeight', barWeight);
    }
    setState(() {});
  }
}
