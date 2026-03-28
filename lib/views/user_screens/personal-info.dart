import 'package:flutter/material.dart';
import 'package:jms/models/user_model.dart';
import 'package:jms/view_models/auth/user_view_model.dart';
import 'package:jms/views/user_screens/edit_profile_screen.dart';
import '/helper/style.dart' as style;
import 'package:provider/provider.dart';
class PersonalInfoPage extends StatefulWidget {
  PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.loadUserFromPreferences(); // 🔥 Fetch user data when screen loads
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final user = userViewModel.currentUser;
  
    return Scaffold(
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
      body: _buildBody(userViewModel),
    );
  }

  Widget _buildBody(UserViewModel userViewModel) {
    final user = userViewModel.currentUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator()); //  Show loader while fetching data
    }

    return RefreshIndicator(
      onRefresh: () async {
        await userViewModel.loadUserFromPreferences();   //  Refresh data on pull
        setState(() {}); // Force UI update
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(), // Required for pull-to-refresh
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
             Image.network(
              
  'https://jalmanagementsystem.com/public/uploads/${user.profileImagePath}?t=${DateTime.now().millisecondsSinceEpoch}',
  loadingBuilder: (BuildContext context, Widget child,
      ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    } else {
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    }
  },
  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
    return Text('Failed to load image');
  },
),

              Container(
                padding: EdgeInsets.all(16),
                decoration: style.bottomBorder(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit"),
                    IconButton(
                        onPressed: () async {
                          // 🚀 Await result from EditProfilePage
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                      userId: user.id ?? 0,
                                    )),
                          );

                          if (result == true) {
                            // ✅ Refresh data after returning
                            await userViewModel.loadUserFromPreferences();
                            setState(() {}); // Force UI update
                          }
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
              ),
              _buildRow('Email', user.email),
              _buildRow('Name', user.name),
              _buildRow('Address', user.address),
              _buildRow('Phone Number', user.phoneNumber),
              _buildRow('Category', user.category),
              _buildRow('ID Card No', user.idCardNo),
              _buildRow('Zone ID', user.zoneId),
            ],
          ),
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
