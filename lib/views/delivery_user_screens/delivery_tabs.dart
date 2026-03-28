import 'package:flutter/material.dart';
import 'package:jms/views/delivery_user_screens/ongoing_orders.dart';
import 'package:jms/views/delivery_user_screens/orders_history.dart';
import 'package:jms/views/delivery_user_screens/staff_account.dart';
import 'package:jms/views/delivery_user_screens/staff_expense.dart';

import '/helper/style.dart' as style;

class DeliveryTabs extends StatefulWidget {
  DeliveryTabs({Key? key, Title? title}) : super(key: key);
  final String title = '';
  static const String page_id = 'Tabs';

  @override
  _TabsExampleState createState() => _TabsExampleState();
}

class _TabsExampleState extends State<DeliveryTabs> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: (TabBar(
          labelColor: style.appColor,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 0),
          unselectedLabelColor: Color.fromARGB(255, 122, 122, 122),
          indicatorColor: Colors.transparent,
          labelPadding: EdgeInsets.all(0),
          labelStyle: TextStyle(
            fontFamily: 'regular',
            fontSize: 10,
          ),
          onTap: (int index) => setState(() => _currentIndex = index),
          tabs: [
            Tab(icon: Icon(Icons.local_mall_outlined), text: 'Ongoing Orders'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            // Tab(icon: Icon(Icons.local_mall_outlined), text: 'My Order'),
            Tab(icon: Icon(Icons.attach_money), text: 'Expenses'),
            Tab(icon: Icon(Icons.people_outline), text: 'Account'),
          ],
        )),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            OngoingOrders(),
            OrderHistoryPage(),
            ExpensesPage(),
            StaffAccountPage(),
          ],
        ),
      ),
    );
  }
}
