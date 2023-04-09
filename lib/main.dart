import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController modal = TextEditingController();
  TextEditingController bunga = TextEditingController();
  TextEditingController lama = TextEditingController();
  double? mno = 0, mn = 0, mo = 0, b = 0, n = 0;
  String mnString = '', formattedValue = '0';
  bungaMajemuk() {
    setState(() {
      mo = double.parse(modal.text.replaceAll(',', ''));
      b = double.parse(bunga.text);
      n = double.parse(lama.text);
      mno = (mo! * pow((1 + (b! / 100)), n!));
      // membulatkan hasil jadi 2 angka di belakang koma
      mnString = mno!.toStringAsFixed(2);
      mn = double.parse(mnString);
      // Menambah koma di hasil
      formattedValue = mn!.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},');
    });
  }

  // assign focusNode untuk focus pada textfield
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GestureDetector(
          onTap: () {
            // mematikan focusNode pada semua textfield
            // ketika tap semua diluar textfield
            focusNode1.unfocus();
            focusNode2.unfocus();
            focusNode3.unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Compound Interest'),
              backgroundColor: Colors.amber,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Rp $formattedValue',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Modal awal
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: modal,
                    focusNode: focusNode1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter()
                    ],
                    decoration: InputDecoration(
                        labelText: 'Modal Awal',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                ),
                // Besar bunga
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: bunga,
                    focusNode: focusNode2,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Besar Bunga (%)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                ),
                // Lama
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: lama,
                    focusNode: focusNode3,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Lama (tahun)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Button hitung bunga majemuk
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            focusNode1.unfocus();
                            focusNode2.unfocus();
                            focusNode3.unfocus();
                            bungaMajemuk();
                          },
                          child: const Text('Hitung Bunga Majemuk')),
                      const SizedBox(
                        height: 10,
                      ),
                      // Button clear
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            focusNode1.unfocus();
                            focusNode2.unfocus();
                            focusNode3.unfocus();
                            modal.clear();
                            bunga.clear();
                            lama.clear();
                            setState(() {
                              formattedValue = '0';
                            });
                          },
                          child: const Text('Clear')),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
