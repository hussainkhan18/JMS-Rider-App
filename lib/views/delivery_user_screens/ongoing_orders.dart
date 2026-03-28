import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:jms/models/staff_model.dart';
import 'package:jms/services/notification_service.dart';
import 'package:jms/view_models/riderlocation_view_model.dart';
import 'package:jms/view_models/staff_view_model.dart';
import 'package:jms/views/delivery_user_screens/orders_history.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OngoingOrders extends StatefulWidget {
  @override
  State<OngoingOrders> createState() => _OngoingOrdersState();
}

class _OngoingOrdersState extends State<OngoingOrders> {
  Future<List<Order>>? futureOrders;
  List<Order> deliveredOrders = [];
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isUpdatingStatus = false; // Prevent multiple simultaneous updates
  double? _latitude;
  double? _longitude;
  Timer? locationUpdateTimer;
  Set<int> _updatingOrders = {}; // Track which orders are being updated

  late StreamSubscription<Position> _positionStream;
  late final riderId;
  @override
  void initState() {
    super.initState();
    // loadRiderId();

    final staffViewModel = Provider.of<StaffViewModel>(context, listen: false);
    final user = staffViewModel.currentStaff;
    riderId = staffViewModel.currentStaff?.id;
    if (user != null) {
      futureOrders = fetchOrders(user.id.toString());
      _initializeLocationServices();
    } else {
      futureOrders = Future.error('User is not logged in');
    }
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    stopLocationUpdateTimer();
    super.dispose();
  }

  void _initializeLocationServices() async {
    try {
      await _getCurrentLocationUpdate();
    } catch (e) {
      print('Error initializing location services: $e');
    }
  }

  Future<List<Order>> fetchOrders(String staffId) async {
    try {
      final response = await http.get(
        Uri.parse('https://jalmanagementsystem.com/api/get_orders/$staffId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json['success']) {
          List<dynamic> data = json['data'];
          return data.map((order) => Order.fromJson(order)).toList();
        } else {
          throw Exception(
              'API returned success: false - ${json['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<void> _getCurrentLocationUpdate() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      // Cancel existing stream if any
      _positionStreamSubscription?.cancel();

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
        (Position position) {
          if (mounted) {
            setState(() {
              _latitude = position.latitude;
              _longitude = position.longitude;
            });
            print(
                "Location updated - Longitude: $_longitude, Latitude: $_latitude");
          }
        },
        onError: (error) {
          print("Location stream error: $error");
        },
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void refreshPage() {
    if (mounted) {
      setState(() {
        final staffId = Provider.of<StaffViewModel>(context, listen: false)
            .currentStaff
            ?.id
            .toString();
        if (staffId != null) {
          futureOrders = fetchOrders(staffId);
        }
      });
    }
  }

  void startLocationUpdateTimer(Order order, int status) {
    // Prevent multiple timers
    stopLocationUpdateTimer();

    // Increased from 10s to 30s to avoid rate limiting (429 errors)
    locationUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _getCurrentLocationUpdate();
      // Only update location, don't update status here to avoid conflicts
      if (_latitude != null && _longitude != null) {
        _updateOrderLocation(order);
      }
    });
  }

  // Separate method to update only location
  Future<void> _updateOrderLocation(Order order) async {
    if (_latitude == null || _longitude == null) return;

    try {
      await http.post(
        Uri.parse(
            'https://jalmanagementsystem.com/api/update_location/${order.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'longitude': _longitude.toString(),
          'latitude': _latitude.toString(),
        }),
      );
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  void stopLocationUpdateTimer() {
    locationUpdateTimer?.cancel();
    locationUpdateTimer = null;
  }

  void _stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // int riderId = 0;

  // Future<void> loadRiderId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final staffIdString = prefs.getString('staff_id');

  //   if (staffIdString != null) {
  //     riderId = int.tryParse(staffIdString) ?? 0;
  //     debugPrint("✅ Rider ID loaded: $riderId");
  //   } else {
  //     debugPrint("❌ No staff_id found in SharedPreferences");
  //   }
  // }

  Future<void> updateOrderStatus(Order order, int status,
      {String? emptyBottles, double? cashReceived, double? balance}) async {
    // Prevent multiple simultaneous updates for the same order
    if (_updatingOrders.contains(order.id)) {
      print('Order ${order.id} is already being updated');
      return;
    }

    _updatingOrders.add(order.id);

    try {
      final requestData = <String, dynamic>{
        'status': status,
      };

      // Add timestamp based on status
      switch (status) {
        case 2:
          requestData['process_at'] = order.processAt?.toIso8601String() ??
              DateTime.now().toIso8601String();
          break;
        case 3:
          requestData['dispatched_at'] =
              order.dispatchedAt?.toIso8601String() ??
                  DateTime.now().toIso8601String();
          if (_latitude != null && _longitude != null) {
            final riderLocationProvider =
                Provider.of<RiderLocationProvider>(context, listen: false);

            // 🧪 Use this during testing:
            riderLocationProvider.startLocationUpdatesByTime(riderId, order.id);

            // 🚀 Or comment above and use this for production:
            // riderLocationProvider.startLocationUpdatesByDistance(riderId, order.id);
          }

          break;
        case 4:
          requestData['delivered_at'] = order.deliveredAt?.toIso8601String() ??
              DateTime.now().toIso8601String();
          break;
      }

      // Add optional fields
      if (emptyBottles != null) requestData['bottle_recieved'] = emptyBottles;
      if (cashReceived != null) requestData['cash_received'] = cashReceived;
      if (balance != null) requestData['balance'] = balance;
      if (_longitude != null) requestData['longitude'] = _longitude.toString();
      if (_latitude != null) requestData['latitude'] = _latitude.toString();

      print('Updating order ${order.id} with data: $requestData');

      final response = await http
          .post(
            Uri.parse('https://jalmanagementsystem.com/api/status/${order.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: 30)); // Add timeout

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == 'true' || json['success'] == true) {
          print("Successfully updated order ${order.id} status to $status");

          // Refresh the orders list
          if (mounted) {
            refreshPage();
          }

          // Show success message
          if (mounted) {
            _showSnackbar(context, 'Order status updated successfully');
          }
        } else {
          throw Exception(
              'API returned success: false - ${json['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
      if (mounted) {
        _showSnackbar(context, 'Failed to update order status: $e');
      }
      rethrow;
    } finally {
      _updatingOrders.remove(order.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Delivery Man View'),
      ),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: refreshPage,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                refreshPage();
                await futureOrders; // ensure refresh waits
              },
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200),
                  Center(child: Text('No orders found')),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: refreshPage,
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          } else {
            List<Order> orders = snapshot.data!.reversed.toList();

            return RefreshIndicator(
              onRefresh: () async {
                refreshPage();
                await futureOrders; // ensures loader completes
              },
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                itemCount: orders.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Ongoing Orders',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final order = orders[index - 1];
                  return _buildOrderCard(context, order, buttonWidth);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, Order order, double buttonWidth) {
    // Check if the order is already delivered
    if (order.status == 4 || deliveredOrders.contains(order)) {
      return SizedBox.shrink();
    }

    String deliveredDate = '';
    if (order.assignedAt != null) {
      deliveredDate = DateFormat.yMd().format(order.assignedAt!);
    }

    bool isUpdating = _updatingOrders.contains(order.id);

    return Card(
      elevation: 4,
      color: order.getStatusColor(),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Date $deliveredDate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text('Address: ${order.address}',
                    style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text('Customer Empty Bottles: ${order.bottles}',
                    style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.itemNames.asMap().entries.map((entry) {
                    int index = entry.key;
                    String itemName = entry.value;
                    double itemPrice = order.unitPrices[index];
                    return Text(
                      '$itemName: Rs.${itemPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  'Total Amount: Rs.${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              if (isUpdating)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusButton(
                      context: context,
                      order: order,
                      targetStatus: 2,
                      buttonText: 'Preparing',
                      buttonWidth: buttonWidth,
                    ),
                    _buildStatusButton(
                      context: context,
                      order: order,
                      targetStatus: 3,
                      buttonText: 'Dispatched',
                      buttonWidth: buttonWidth,
                    ),
                    _buildStatusButton(
                      context: context,
                      order: order,
                      targetStatus: 4,
                      buttonText: 'Delivered',
                      buttonWidth: buttonWidth,
                      isDelivered: true,
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  String mapsUrl =
                      generateGoogleMapsUrl(order.latitude, order.longitude);
                  launchUrl(Uri.parse(mapsUrl));
                },
                child: Text(
                  'Get Google Directions',
                  style: TextStyle(fontSize: 11, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required Order order,
    required int targetStatus,
    required String buttonText,
    required double buttonWidth,
    bool isDelivered = false,
  }) {
    bool canUpdate = _canUpdateToStatus(order, targetStatus);
    bool isCurrentStatus = order.status == targetStatus;

    return ElevatedButton(
      onPressed: canUpdate
          ? () {
              if (isDelivered) {
                _showDeliveredDialog(context, order);
              } else {
                _showConfirmationDialog(
                    context, order, targetStatus, buttonText);
              }
            }
          : () {
              String message = _getStatusMessage(order, targetStatus);
              _showSnackbar(context, message);
            },
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 11,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(buttonWidth, 35),
        backgroundColor: isCurrentStatus
            ? _getStatusBackgroundColor(targetStatus)
            : Colors.white,
      ),
    );
  }

  bool _canUpdateToStatus(Order order, int targetStatus) {
    switch (targetStatus) {
      case 2: // Preparing
        return order.status < 2;
      case 3: // Dispatching
        return order.status == 2;
      case 4: // Delivered
        return order.status == 3;
      default:
        return false;
    }
  }

  String _getStatusMessage(Order order, int targetStatus) {
    if (order.status == 4) {
      return 'Order is already complete.';
    }

    switch (targetStatus) {
      case 2:
        if (order.status >= 2) return 'Order is already preparing or beyond.';
        break;
      case 3:
        if (order.status == 3) return 'Order is already dispatching.';
        if (order.status != 2)
          return 'Order must be in preparing status first.';
        break;
      case 4:
        if (order.status != 3)
          return 'Order must be in dispatching status first.';
        break;
    }
    return 'Cannot update status directly.';
  }

  Color _getStatusBackgroundColor(int status) {
    switch (status) {
      case 2:
        return Color.fromARGB(255, 255, 243, 229);
      case 3:
        return Color.fromARGB(255, 255, 229, 229);
      case 4:
        return Color.fromARGB(255, 229, 255, 242);
      default:
        return Colors.white;
    }
  }

  String generateGoogleMapsUrl(String latitude, String longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  void _showSnackbar(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, Order order, int status, String statusText) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Confirm Status Update",
      desc: "Do you really want to update the status to $statusText?",
      style: AlertStyle(
        animationType: AnimationType.fromTop,
        isOverlayTapDismiss: false,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey),
        ),
        titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        descStyle: TextStyle(fontSize: 16),
      ),
      buttons: [
        DialogButton(
          child: Text("Cancel",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.grey,
        ),
        DialogButton(
          child:
              Text("Yes", style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              await updateOrderStatus(order, status);
              if (status == 3) {
                startLocationUpdateTimer(order, status);
              }
            } catch (e) {
              _showSnackbar(context, 'Failed to update status: $e');
            }
          },
          color: Colors.green,
        ),
      ],
    ).show();
  }

  void _showDeliveredDialog(BuildContext context, Order order) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    double buttonWidth = dialogWidth * 0.3;

    TextEditingController bottlesController = TextEditingController();
    TextEditingController cashReceivedController = TextEditingController();
    TextEditingController balanceController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: "Delivered",
      style: AlertStyle(
        animationType: AnimationType.fromTop,
        isOverlayTapDismiss: false,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.blueAccent),
        ),
        titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            TextFormField(
              controller: bottlesController,
              decoration: InputDecoration(
                labelText: 'Received Empty Bottles',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_drink),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: cashReceivedController,
              decoration: InputDecoration(
                labelText: 'Cash Received',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                double totalAmount = order.totalAmount;
                double cashReceived = double.tryParse(value ?? '') ?? 0.0;

                if (cashReceived > totalAmount) {
                  return 'Cash received cannot exceed total amount (${totalAmount.toStringAsFixed(2)})';
                }
                if (cashReceived < 0) {
                  return 'Cash received cannot be negative';
                }
                return null;
              },
              onChanged: (value) {
                double totalAmount = order.totalAmount;
                double cashReceived = double.tryParse(value) ?? 0.0;
                double balance = totalAmount - cashReceived;
                balanceController.text = balance.toStringAsFixed(2);
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: balanceController,
              decoration: InputDecoration(
                labelText: 'Balance',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          child: Text("Cancel",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.grey,
          width: buttonWidth,
        ),
        DialogButton(
          child:
              Text("Done", style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return; // Block submission if validation fails
            }

            Navigator.of(context).pop();

            try {
              int emptyBottles = int.tryParse(bottlesController.text) ?? 0;
              double cashReceived =
                  double.tryParse(cashReceivedController.text) ?? 0.0;
              double balance = double.tryParse(balanceController.text) ?? 0.0;

              await updateOrderStatus(
                order,
                4,
                emptyBottles: emptyBottles.toString(),
                cashReceived: cashReceived,
                balance: balance,
              );

              stopLocationUpdateTimer();

              if (mounted) {
                setState(() {
                  deliveredOrders.add(order);
                });
              }
            } catch (e) {
              _showSnackbar(context, 'Failed to mark as delivered: $e');
            }
          },
          color: Colors.blueAccent,
          width: buttonWidth,
        ),
      ],
    ).show();
  }
}
