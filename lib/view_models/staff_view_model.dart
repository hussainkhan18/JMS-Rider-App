import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jms/models/staff_model.dart';

class StaffViewModel extends ChangeNotifier {
  Staff? _currentStaff;
  Staff? get currentStaff => _currentStaff;

  Future<void> loadStaffFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final staffData = prefs.getString('staffData');

    if (staffData != null) {
      _currentStaff = Staff.fromJson(json.decode(staffData));
      debugPrint("✅ Staff loaded from preferences: ${_currentStaff?.id}");
      notifyListeners();
    } else {
      debugPrint("⚠️ No staff data found in preferences.");
    }
  }

  Future<void> saveStaffToPreferences(Staff staff) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staffData', json.encode(staff.toJson()));
    _currentStaff = staff;
    debugPrint("✅ Staff saved to preferences: ${staff.id}");
    notifyListeners();
  }

  Future<void> clearStaffPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentStaff = null;
    debugPrint("🧹 Cleared all staff data");
    notifyListeners();
  }

  Future<Map<String, dynamic>> loginStaff(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://jalmanagementsystem.com/api/staff_login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = json.decode(response.body);
      debugPrint("Login Response: $responseData");

      if (response.statusCode == 200 && responseData['user'] != null) {
        final user = responseData['user'];
        debugPrint("Login user Response: $user");
        final staffId = user['id'].toString();
        final accessToken = responseData['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        await prefs.setString('staff_id', staffId);
        await prefs.setString('access_token', accessToken);
        await prefs.setString('user_data', jsonEncode(user));

        final staffModel = Staff.fromJson(user);
        await saveStaffToPreferences(staffModel);

        debugPrint("Staff ID saved: $staffId");
        debugPrint("Access token saved: $accessToken");

        // 🔹 Save FCM Token
        await _saveFcmTokenToServer(staffId, accessToken);

        return {'status': 'success', 'message': responseData['message']};
      } else {
        final errorMsg = responseData['message'] ?? "Login failed";
        debugPrint("❌ Login failed: $errorMsg");
        return {'status': 'error', 'message': errorMsg};
      }
    } catch (e) {
      debugPrint("⚠️ Login error: $e");
      return {'status': 'error', 'message': 'Network error. Please try again.'};
    }
  }

  /// -----------------------------
  /// 🔹 Save FCM token to server
  /// -----------------------------
  Future<void> _saveFcmTokenToServer(String staffId, String accessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString("fcm_token");

      if (fcmToken == null || fcmToken.isEmpty) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          await prefs.setString("fcm_token", fcmToken);
          debugPrint("🔑 New FCM Token generated: $fcmToken");
        }
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        final saveTokenResponse = await http.post(
          Uri.parse('https://jalmanagementsystem.com/api/save-token'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'staff_id': staffId,
            'fcm_token': fcmToken,
          }),
        );

        if (saveTokenResponse.statusCode == 200) {
          debugPrint("✅ FCM Token saved successfully to server");
        } else {
          debugPrint("❌ Failed to save FCM Token: ${saveTokenResponse.body}");
        }
      } else {
        debugPrint("⚠️ No FCM token available to save");
      }
    } catch (e) {
      debugPrint("⚠️ Error saving FCM token to server: $e");
    }
  }

  /// -----------------------------
  /// 🔹 Getters
  /// -----------------------------
  Future<String?> getStaffId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('staff_id');
    debugPrint("🔍 Retrieved staff ID: $id");
    return id;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    debugPrint("🔍 Retrieved access token: $token");
    return token;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) return jsonDecode(data);
    debugPrint("⚠️ No user data found");
    return null;
  }

  /// -----------------------------
  /// 🔹 Logout
  /// -----------------------------
  Future<void> logoutStaff() async {
    await clearStaffPreferences();
    debugPrint("🚪 Logged out successfully");
  }

  /// -----------------------------
  /// 🔹 Check login state
  /// -----------------------------
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null &&
        prefs.getString('staff_id') != null;
  }
}
