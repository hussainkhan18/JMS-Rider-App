import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jms/models/user_model.dart';
import 'package:jms/view_models/auth/user_view_model.dart';
import 'package:jms/views/login_signup_screens/login.dart';
import '../../helper/style.dart' as style;
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  SignupPage({Key? key, Title? title}) : super(key: key);
  final String title = '';
  static const String page_id = 'Register';

  @override
  State<SignupPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<SignupPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController idCardNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();
  final TextEditingController zoneIdController = TextEditingController();


  final UserViewModel userViewModel = UserViewModel();

  String _selectedCategory = 'domestic';
  double? _latitude;
  double? _longitude;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      locationController.text = 'Lat: ${_latitude}, Long: ${_longitude}';
    });
  }
  // var image =
  //         await http.MultipartFile.fromPath('profile_img', _imageFile!.path);
  //     request.files.add(image);


  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage; // To hold the picked image

  // Other variables and methods...

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      }
      }

  Future<void> registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      User user = User(
              name: nameController.text,
        address: addressController.text,
        phoneNumber: phoneNumberController.text,
        category: _selectedCategory,
        idCardNo: idCardNoController.text,
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        referralCode: referralCodeController.text,
        zoneId: zoneIdController.text,
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        profileImagePath: _pickedImage?.path, // Pass the image path

      );

      print('Starting registration for user: ${user.toJson()}');
      String result = await userViewModel.registerUser(user, _pickedImage);

      print('Registration result: $result');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor:
              result.contains("successful") ? Colors.green : Colors.red,
        ),
      );

      if (result.contains('Registration successful')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please correct the errors in the form")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: style.appColor),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let\'s get started',
                style: TextStyle(fontFamily: 'semi-bold', fontSize: 24),
              ),
              Text(
                'Create account to see our top picks for you!',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              SizedBox(height: 16),

                  _buildImagePicker(),

              SizedBox(height: 24),
              _buildTextField(nameController, 'Name', Icons.person_outline),
              SizedBox(height: 16),
              _buildTextField(
                  addressController, 'Address', Icons.home_outlined),
              SizedBox(height: 16),
              _buildTextField(
                  phoneNumberController, 'Phone Number', Icons.phone_outlined),
              SizedBox(height: 16),
              _buildCategoryDropdown(),
              SizedBox(height: 16),
              _buildTextField(
                  idCardNoController, 'ID Card No', Icons.credit_card_outlined),
              SizedBox(height: 16),
              _buildTextField(zoneIdController, 'Zone ID', Icons.map_outlined),
              SizedBox(height: 16),
              _buildTextField(emailController, 'Email', Icons.email_outlined,
                  isEmail: true),
              SizedBox(height: 16),
              _buildTextField(
                  passwordController, 'Password', Icons.remove_red_eye_outlined,
                  obscureText: true, isPassword: true),
              SizedBox(height: 16),
              _buildTextField(confirmPasswordController, 'Confirm Password',
                  Icons.remove_red_eye_outlined,
                  obscureText: true, isConfirmPassword: true),
              SizedBox(height: 16),
              _buildTextField(referralCodeController, 'Referral Code',
                  Icons.card_giftcard_outlined),
              SizedBox(height: 16),
              _buildLocationField(),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerCustomer,
                  child: Text('Create Account'),
                  style: style.simpleButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      bool isEmail = false,
      bool isPassword = false,
      bool isConfirmPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: style.inputTextFieldDecoration(label, icon),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        if (isPassword && value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        if (isConfirmPassword && value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: const [
        DropdownMenuItem(value: 'domestic', child: Text('Domestic')),
        DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
        DropdownMenuItem(value: 'corporate', child: Text('Corporate')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      decoration:
          style.inputTextFieldDecoration('Category', Icons.category_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Category is required';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: locationController,
          decoration: style.inputTextFieldDecoration(
              'Location', Icons.location_on_outlined),
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Location is required';
            }
            return null;
          },
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _getCurrentLocation,
          child: Text('Get Current Location'),
          style: style.simpleButton(),
        ),
      ],
    );
  }

   Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pickedImage != null
            ? Image.file(File(_pickedImage!.path), height: 150, width: 150)
            : Text('No image selected'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Select Profile Image'),
          style: style.simpleButton(),
        ),
      ],
    );
  }
}
