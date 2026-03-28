import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jms/helper/style.dart';
import 'package:jms/view_models/staff_view_model.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesState();
}

class _ExpensesState extends State<ExpensesPage> {
  File? _imageFile;
  String? _imagePath;
  bool isVisible = false;
  bool isLoadingCategories = true;

  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionNotes = TextEditingController();

  DateTime selectedDate = DateTime.now();
  Categories? selectedCategory;

  List<Categories> categoriesList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf('.');
    final targetPath = filePath.substring(0, lastIndex) + "_compressed.jpg";

    final XFile? compressedXFile =
        await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    if (compressedXFile == null) return null;

    // 🔥 Convert XFile → File
    return File(compressedXFile.path);
  }

  Future<void> fetchData() async {
    try {
      final staffViewModel =
          Provider.of<StaffViewModel>(context, listen: false);
      final refrelCode = staffViewModel.currentStaff?.refrel_code;

      if (refrelCode == null || refrelCode.isEmpty) {
        print('❌ No refrel code found for current staff');
        setState(() => isLoadingCategories = false);
        return;
      }

      print('📡 Fetching categories for refrel_code=$refrelCode');

      final response = await http.get(Uri.parse(
          'https://jalmanagementsystem.com/api/expense_category?refrel_code=$refrelCode'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        List<Categories> categories =
            data.map((item) => Categories.fromJson(item)).toList();

        setState(() {
          categoriesList = categories;
          isLoadingCategories = false;
        });

        print('✅ Categories loaded: ${categoriesList.length}');
      } else {
        print('❌ Failed to load categories. Status: ${response.statusCode}');
        setState(() => isLoadingCategories = false);
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: appColor),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70, // 🔥 pehle hi size reduce
    );

    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);

      // 🔥 compress image
      File? compressedFile = await compressImage(originalFile);
      if (compressedFile != null) {
        int fileSize = await compressedFile.length();

        // 🔥 size check (2MB)
        if (fileSize > 2 * 1024 * 1024) {
          print("❌ Image still too large");

          Alert(
            context: context,
            type: AlertType.error,
            title: "Image Too Large",
            desc: "Please select an image under 2MB.",
            buttons: [
              DialogButton(
                child: const Text("OK", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.red,
              ),
            ],
          ).show();

          return;
        }

        setState(() {
          _imageFile = compressedFile;
          _imagePath = compressedFile.path;
          isVisible = true;
        });
      }
    }
  }

  Future<void> _sendExpenses() async {
    if (!_formKey.currentState!.validate()) return;

    final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);
    final staffId = staffViewModel.currentStaff?.id;

    if (staffId == null) {
      print('❌ User not logged in');
      return;
    }

    String date = '${selectedDate.toLocal()}'.split(' ')[0];
    int categoryId = selectedCategory?.id ?? 0;
    String amount = amountController.text;
    String notes = descriptionNotes.text;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://jalmanagementsystem.com/api/add_expense'),
    );

    request.fields['date'] = date;
    request.fields['category_id'] = categoryId.toString();
    request.fields['staff_id'] = staffId.toString();
    request.fields['amount'] = amount;
    request.fields['note'] = notes;

    if (_imageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('expense_img', _imageFile!.path));
    }

    print('📤 Sending expense: $date, $categoryId, $staffId, $amount');

    try {
      Alert(
        context: context,
        type: AlertType.none,
        title: "Sending Expense...",
        content: const Column(
          children: [
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
        style:
            const AlertStyle(isOverlayTapDismiss: false, isCloseButton: false),
        buttons: [],
      ).show();

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        print('✅ Expense submitted successfully: $responseBody');

        Alert(
          context: context,
          type: AlertType.success,
          title: "Success",
          desc: "Expense sent successfully.",
          buttons: [
            DialogButton(
              child: const Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                amountController.clear();
                descriptionNotes.clear();
                setState(() {
                  selectedDate = DateTime.now();
                  selectedCategory = null;
                  _imageFile = null;
                  _imagePath = null;
                  isVisible = false;
                });
              },
              color: Colors.green,
            ),
          ],
        ).show();
      } else {
        print('❌ Failed to submit expense: ${response.statusCode}');
        print('Response: $responseBody');
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: "Failed to submit expense. Please try again.",
          buttons: [
            DialogButton(
              child: const Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.red,
            ),
          ],
        ).show();
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('❌ Error submitting expense: $e');
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: "Unexpected error occurred. Try again later.",
        buttons: [
          DialogButton(
            child: const Text("OK", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.red,
          ),
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _selectDate(context),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(appColor),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: appColor),
                  )),
                ),
                child: Text('${selectedDate.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Categories>(
                      value: selectedCategory,
                      onChanged: (Categories? newValue) =>
                          setState(() => selectedCategory = newValue),
                      items: categoriesList.map((category) {
                        return DropdownMenuItem(
                            value: category, child: Text(category.name));
                      }).toList(),
                      dropdownColor: Colors.white,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: appColor, width: 2.0)),
                        border: OutlineInputBorder(),
                        hintText: 'Select category',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
              const SizedBox(height: 16),
              const Text('Amount',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor, width: 2.0)),
                  hintText: 'Enter amount',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter amount'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                controller: descriptionNotes,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor, width: 2.0)),
                  hintText: 'Description Notes',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Image',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(backgroundColor: appColor),
                child: const Text('Take Receipt Picture',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              if (isVisible && _imagePath != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: appColor, width: 1.5),
                  ),
                  child: Image.file(File(_imagePath!),
                      height: 200, width: 150, fit: BoxFit.cover),
                ),
              if (!isVisible)
                const Text('Please add a receipt image',
                    style: TextStyle(color: Colors.red)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _sendExpenses,
                style: ElevatedButton.styleFrom(backgroundColor: appColor),
                child: const Text('Send Expenses',
                    style: TextStyle(color: Colors.white)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class Categories {
  final int id;
  final String name;
  Categories({required this.id, required this.name});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(id: json['id'], name: json['name']);
  }
}
