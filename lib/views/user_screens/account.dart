import 'package:flutter/material.dart';
import 'package:jms/models/user_model.dart';
import 'package:jms/routes/app_routes.dart';
import 'package:jms/view_models/auth/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  static const String page_id = 'Account';

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final Uri _url = Uri.parse('https://flutter.dev');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final user = userViewModel.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: _buildBody(user),
    );
  }

  Widget _buildBody(User? user) {
    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      child: Material(
        // 👈 Ensures InkWell detects taps and shows ripple
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.personalInfoPage);
              },
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: _buildRow('Personal Info'),
            ),
            ElevatedButton(
              onPressed: _launchUrl,
              child: Text('Show Flutter homepage'),
            ),
            // InkWell(
            //   onTap: _launchUrl,
            //   splashColor: Colors.blue.withOpacity(0.2),
            //   highlightColor: Colors.grey.withOpacity(0.1),
            //   child: _buildRow('About'),
            // ),
            InkWell(
              onTap: () {},
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: _buildRow('Help'),
            ),
            InkWell(
              onTap: () async {
                final userViewModel =
                    Provider.of<UserViewModel>(context, listen: false);
                await userViewModel.logoutUser();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.loginPage,
                  (route) => false,
                );
              },
              splashColor: Colors.red.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: _buildRow('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            val,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
        ],
      ),
    );
  }
}
