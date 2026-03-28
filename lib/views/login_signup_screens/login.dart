// import 'package:flutter/material.dart';
// import 'package:jms/helper/style.dart';
// import 'package:jms/routes/app_routes.dart';
// import 'package:jms/view_models/auth/user_view_model.dart';
// import 'package:jms/view_models/staff_view_model.dart';
// import 'package:jms/widgets/simple_btn.dart';
// import 'package:provider/provider.dart';
// import '../../helper/style.dart' as style;

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key, Title? title}) : super(key: key);
//   final String title = '';
//   static const String page_id = 'Login';

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//     final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);

//     await userViewModel.loadUserFromPreferences();
//     if (userViewModel.currentUser != null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.userTabs);
//       return;
//     }

//     await staffViewModel.loadStaffFromPreferences();
//     if (staffViewModel.currentStaff != null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.deliveryTabs);
//       return;
//     }
//   }

//   Future<void> loginUser() async {
//     setState(() {
//       _errorMessage = null;
//     });

//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       setState(() {
//         _errorMessage = 'Enter both email and password';
//       });
//       return;
//     }

//     final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//     final result = await userViewModel.loginUser(email, password);

//     if (result['status'] == 'success') {
//       Navigator.pushReplacementNamed(context, AppRoutes.userTabs);
//     } else {
//       setState(() {
//         _errorMessage = result['message'];
//       });

//       // Show the error message in a Snackbar
//     }
//   }

//   Future<void> loginStaff() async {
//     setState(() {
//       _errorMessage = null;
//     });

//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       setState(() {
//         _errorMessage = 'Enter both email and password';
//       });
//       return;
//     }

//     final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);
//     final result = await staffViewModel.loginStaff(email, password);

//     if (result['status'] == 'success') {
//       // Navigate to the next screen upon successful login
//       Navigator.pushReplacementNamed(context, AppRoutes.deliveryTabs);
//     } else {
//       // Display error message in case of unsuccessful login
//       setState(() {
//         _errorMessage = result['message'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     return SingleChildScrollView(
//       child: SafeArea(
//         child: Container(
//           width: double.infinity,
//           height: MediaQuery.of(context).size.height -
//               MediaQuery.of(context).padding.top -
//               MediaQuery.of(context).padding.bottom,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child:
//                     Image.asset('assets/images/app_icon_rider.png', width: 100),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Welcome to JRCS',
//                 style: TextStyle(fontFamily: 'semi-bold', fontSize: 26),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Shop everything you need without the trip to the supermarket.',
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 40),
//               const Text(
//                 'Login to continue',
//                 style: TextStyle(fontFamily: 'semi-bold', fontSize: 24),
//               ),
//               const SizedBox(height: 24),
//               TextField(
//                 controller: emailController,
//                 decoration: style.inputTextFieldDecoration(
//                     'Email', Icons.email_outlined),
//               ),
//               const SizedBox(height: 30),
//               TextField(

//                 controller: passwordController,
//                 decoration: style.inputTextFieldDecoration(
//                     'Password', Icons.lock_outline),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 30),
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: Center(
//                     child: Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ),
//               SimpleButton(
//                 btnName: 'Login',
//                 onPressed: loginStaff,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:jms/helper/style.dart';
import 'package:jms/routes/app_routes.dart';
import 'package:jms/view_models/auth/user_view_model.dart';
import 'package:jms/view_models/staff_view_model.dart';
import 'package:jms/widgets/pass_field.dart';
import 'package:jms/widgets/simple_btn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/style.dart' as style;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, Title? title}) : super(key: key);
  final String title = '';
  static const String page_id = 'Login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _errorMessage;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);

    await userViewModel.loadUserFromPreferences();
    if (userViewModel.currentUser != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.userTabs);
      return;
    }

    await staffViewModel.loadStaffFromPreferences();
    if (staffViewModel.currentStaff != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.deliveryTabs);
      return;
    }
  }

  Future<void> loginUser() async {
    setState(() {
      _errorMessage = null;
      isloading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Enter both email and password';
        isloading = false;
      });
      return;
    }

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final result = await userViewModel.loginUser(email, password);

    if (result['status'] == 'success') {
      Navigator.pushReplacementNamed(context, AppRoutes.userTabs);
      isloading = false;
    } else {
      setState(() {
        _errorMessage = result['message'];
        isloading = false;
      });

      // Show the error message in a Snackbar
    }
  }

  Future<void> loginStaff() async {
    setState(() {
      _errorMessage = null;
      isloading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Enter both email and password';
      });
      return;
    }

    final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);
    final result = await staffViewModel.loginStaff(email, password);

    if (result['status'] == 'success') {
      final staffId = staffViewModel.currentStaff?.id.toString();
      if (staffId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staff_id', staffId);
        await prefs
            .setStringList('previous_orders', []); // Clear previous orders
        print('Saved staff ID: $staffId to SharedPreferences');
      } else {
        print('Warning: No staff ID found after login');
      }
      Navigator.pushReplacementNamed(context, AppRoutes.deliveryTabs);
    } else {
      // Display error message in case of unsuccessful login
      setState(() {
        _errorMessage = result['message'];
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child:
                    Image.asset('assets/images/app_icon_rider.png', width: 100),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Welcome to',
                    style: TextStyle(fontFamily: 'semi-bold', fontSize: 26),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        "JRCS",
                        textStyle: const TextStyle(
                            fontFamily: 'semi-bold',
                            fontSize: 24,
                            color: appColor),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    repeatForever: true,
                    pause: const Duration(milliseconds: 1000),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Shop everything you need without the trip to the supermarket.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Text(
                    'Login to ',
                    style: TextStyle(fontFamily: 'semi-bold', fontSize: 24),
                  ),
                  Text(
                    'Continue',
                    style: TextStyle(
                        fontFamily: 'semi-bold', fontSize: 24, color: appColor),
                  )
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: style.inputTextFieldDecoration(
                    'Email', Icons.email_outlined),
              ),
              const SizedBox(height: 30),
              // TextField(
              //   controller: passwordController,
              //   decoration: style.inputTextFieldDecoration(
              //       'Password', Icons.lock_outline,),
              //   obscureText: true,
              // ),
              PasswordField(
                controller: passwordController,
                label: 'Password',
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              SimpleButton(
                btnName: isloading
                    ? const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'medium',
                                fontSize: 18,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'medium',
                          fontSize: 18,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                onPressed: loginStaff,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
