import 'package:flutter/material.dart';
import 'package:jms/models/staff_model.dart';
import 'package:jms/view_models/staff_view_model.dart';
import '/helper/style.dart' as style;
import 'package:provider/provider.dart';

class StaffPersonalInfoPage extends StatefulWidget {
  StaffPersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<StaffPersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<StaffPersonalInfoPage> {
  @override
  Widget build(BuildContext context) {
    final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);
    final staff = staffViewModel.currentStaff;
    print(" staff id $staff");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: style.appColor,
        ),
        title: Text('Personal Info'),
        centerTitle: false,
        titleTextStyle: style.pageTitle(),
      ),
      body: _buildBody(staff),
    );
  }

  Widget _buildBody(Staff? staff) {
    if (staff == null) {
      return Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(staff.companyImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            _buildRow('Company', staff.companyName),
            _buildRow('Email', staff.email),
            _buildRow('Name', staff.name),
            _buildRow('Address', staff.address),
            _buildRow('Phone Number', staff.phoneNumber),
            _buildRow('ID Card No', staff.idCardNo),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: style.bottomBorder(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
