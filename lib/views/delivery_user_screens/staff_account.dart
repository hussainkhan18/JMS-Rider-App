import 'package:flutter/material.dart';
import 'package:jms/models/staff_model.dart';
import 'package:jms/routes/app_routes.dart';
import 'package:jms/view_models/staff_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffAccountPage extends StatefulWidget {
  StaffAccountPage({Key? key, Title? title}) : super(key: key);
  final String title = '';
  static const String page_id = 'Account';

  @override
  State<StaffAccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<StaffAccountPage> {
  final Uri _url = Uri.parse('https://jalmanagementsystem.com/');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffViewModel = Provider.of<StaffViewModel>(context);
    final staff = staffViewModel.currentStaff;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Account'),
        centerTitle: false,
      ),
      body: _buildBody(staff),
    );
  }

  Widget _buildBody(Staff? staff) {
    if (staff == null) {
      return const Center(child: Text('No user data available'));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.staffPersonalInfoPage);
            },
            child: _buildRow('Personal Info'),
          ),
          InkWell(
            onTap: () {
              _launchUrl();
            },
            child: _buildRow('About'),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.helpPage);
            },
            child: _buildRow('Help'),
          ),
          InkWell(
            onTap: () async {
              final staffViewModel =
                  Provider.of<StaffViewModel>(context, listen: false);
              await staffViewModel.logoutStaff();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.loginPage,
                (route) => false,
              );
            },
            child: _buildRow('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String val) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(val),
          const Icon(Icons.keyboard_arrow_right, color: Colors.grey)
        ],
      ),
    );
  }
}
