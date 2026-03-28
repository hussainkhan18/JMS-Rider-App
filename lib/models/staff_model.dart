import 'package:flutter/material.dart';

class Staff {
  final int id;
  final String name;
  final String address;
  final String companyImg;
  final String staffImg;
  final String phoneNumber;
  final String email;
  final String idCardNo;
  final String createdAt;
  final String updatedAt;
  final String companyName;
  final String refrel_code; // ← Note: this matches API key

  Staff({
    required this.id,
    required this.name,
    required this.companyName,
    required this.companyImg,
    required this.staffImg,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.idCardNo,
    required this.createdAt,
    required this.updatedAt,
    required this.refrel_code,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      companyName: json['company_name'] ?? '',
      companyImg: json['company_img'] ?? '',
      staffImg: json['staff_img'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      idCardNo: json['id_card_no'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      refrel_code: json['refrel_code'].toString(), // ✅ fixed spelling + string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'id_card_no': idCardNo,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'company_name': companyName,
      'company_img': companyImg,
      'staff_img': staffImg,
      'refrel_code': refrel_code,
    };
  }

  @override
  String toString() {
    return 'Staff{id: $id, name: $name, refrel_code: $refrel_code}';
  }
}

class Order {
  final int id;
  int status;
  final String bottles;
  final double totalAmount;
  final double cashReceived;
  final double balance;
  final String address;
  final DateTime createdAt;
  final DateTime? processAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? assignedAt;
  final List<String> itemNames;
  final List<double> unitPrices;
  final String latitude;
  final String longitude;
  final String customerName;
  final String quantity;

  Order({
    required this.status,
    required this.id,
    required this.bottles,
    required this.totalAmount,
    required this.cashReceived,
    required this.balance,
    required this.address,
    required this.createdAt,
    this.processAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.assignedAt,
    required this.itemNames,
    required this.unitPrices,
    required this.latitude,
    required this.longitude,
    required this.customerName,
    required this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<String> itemNames = List<String>.from(json['item_names'] ?? []);
    List<String> unitPricesStr = (json['unit_price'] as String).split(',');
    List<double> unitPrices =
        unitPricesStr.map((e) => double.parse(e.trim())).toList();

    return Order(
      id: json['id'],
      quantity: json['buying_qty'],
      bottles: json['bottles'] ?? '0',
      customerName: json['customer_name'] ?? 'unknown Customer',
      status: int.tryParse(json['status'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      cashReceived: double.tryParse(json['cash_received'].toString()) ?? 0.0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      address: json['address'] ?? 'Unknown',
      latitude: json['latitude'] ?? 'null',
      longitude: json['longitude'] ?? 'null',
      createdAt: DateTime.parse(json['created_at']),
      processAt: json['process_at'] != null
          ? DateTime.parse(json['process_at'])
          : null,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      dispatchedAt: json['dispatched_at'] != null
          ? DateTime.parse(json['dispatched_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      itemNames: itemNames,
      unitPrices: unitPrices,
    );
  }

  Color getStatusColor() {
    switch (status) {
      case 2:
        return const Color.fromARGB(255, 255, 243, 229); // In Process
      case 3:
        return const Color.fromARGB(255, 255, 229, 229); // Delivering
      case 4:
        return const Color.fromARGB(255, 229, 255, 242); // Delivered
      default:
        return Colors.white; // Unknown status
    }
  }

  Color getStatusTextColor() {
    switch (status) {
      case 2:
        return const Color.fromARGB(255, 255, 194, 76); // In Process
      case 3:
        return const Color.fromARGB(255, 255, 56, 56); // Delivering
      case 4:
        return const Color.fromARGB(255, 56, 204, 113); // Delivered
      default:
        return Colors.grey; // Unknown status
    }
  }
}
