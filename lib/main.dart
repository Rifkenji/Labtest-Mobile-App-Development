import 'package:flutter/material.dart';
import 'Model/bmicalc.dart';
import 'controller/sqlite_db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BMICalculator(),
    );
  }
}

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();


}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmivalueController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  String genders = " ";



  void initData() async {
    List<Map<String, dynamic>> data = await SQLiteDB().queryAll(bmicalculate.SQLiteTable);
    if (data.isNotEmpty) {
      Map<String, dynamic> lastEntry = data.last;
      fullnameController.text = lastEntry['username'];
      heightController.text = lastEntry['height'].toString();
      weightController.text = lastEntry['weight'].toString();
      genders = lastEntry['gender'];
      calculateBMI();
      statusController.text = lastEntry['bmi_status'].toString();
    }
  }


  void _addbmi() async {
    String username = fullnameController.text.trim();
    String weight = weightController.text.trim();
    String height = heightController.text.trim();
    String gender = genders.trim();

    if (username.isNotEmpty && weight.isNotEmpty && height.isNotEmpty && gender.isNotEmpty) {
      try {
        double parsedWeightInKg = double.parse(weight);
        double parsedHeightInCm = double.parse(height);

        setState(() {
          calculateBMI();
        });
        String bmiStatus = statusController.text.trim();
        bmicalculate bmicalc = bmicalculate(username, parsedWeightInKg, parsedHeightInCm, gender, bmiStatus);
        await bmicalc.save();
        setState(() {
          fullnameController.clear();
          heightController.clear();
          weightController.clear();
        });

      } catch (e) {
        print("Error parsing double: $e");
      }
    } else {
      print("Invalid input data");
    }
  }



  void calculateBMI() {

    // calculate bmi
    setState(() {
      double _height = double.parse(heightController.text) / 100;
      double _weight = double.parse(weightController.text);
      double bmi = _weight / (_height * _height);
      bmivalueController.text = bmi.toStringAsFixed(2);

      if (genders == 'Male') {
        if (bmi < 18.5)
          statusController.text = 'Underweight. Careful during strong wind!';
        else if (bmi >= 18.5 && bmi <= 24.9)
          statusController.text = 'That’s ideal! Please maintain';
        else if (bmi >= 25.0 && bmi <= 29.9)
          statusController.text = 'Overweight! Work out please';
        else
          statusController.text = 'Whoa Obese! Dangerous mate!';
      } else if (genders == 'Female') {
        if (bmi < 16)
          statusController.text = 'Underweight. Careful during strong wind!';
        else if (bmi >= 16 && bmi <= 22)
          statusController.text = 'That’s ideal! Please maintain';
        else if (bmi >= 22 && bmi <= 27)
          statusController.text = 'Overweight! Work out please';
        else
          statusController.text = 'Whoa Obese! Dangerous mate!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('BMI Calculator'),
        ),
        body: SingleChildScrollView (
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: fullnameController,
                    decoration: InputDecoration(
                      labelText: 'Your Fullname',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: heightController,
                    decoration: InputDecoration(
                      labelText: 'Height in cm; 170',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight in KG',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: bmivalueController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Bmi Value',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Male'),
                        leading: Radio(
                          value: 'Male',
                          groupValue: genders,
                          onChanged: (String? value) {
                            setState(() {
                              genders = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Female'),
                        leading: Radio(
                          value: 'Female',
                          groupValue: genders,
                          onChanged: (String? value) {
                            setState(() {
                              genders = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: _addbmi,
                  child: Text('Calculate BMI and Save'),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(statusController.text ,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                  ),
                )

              ],
            )
            )
        );
    }
}