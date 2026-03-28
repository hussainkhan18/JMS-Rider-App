import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jms/view_models/auth/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EditProfilePage extends StatefulWidget {
  final int userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate() || _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all fields and select an image.")),
    );
    return;
  }

  final userViewModel = Provider.of<UserViewModel>(context, listen: false);
  bool success = await userViewModel.updateUserProfile(
    widget.userId,
    _addressController.text,
    _phoneController.text,
    _selectedImage!,
  );

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));

    // 🔥 Go back and refresh the previous screen
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image with Upload Button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Form Fields
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? "Phone number is required" : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? "Address is required" : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 25),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
