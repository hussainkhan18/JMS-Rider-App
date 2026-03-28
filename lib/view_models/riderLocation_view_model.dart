import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jms/models/riderlocation_model.dart';

class RiderLocationProvider with ChangeNotifier {
  Position? _lastPosition;
  Timer? _locationTimer;

  /// ✅ API endpoint
  final String _apiUrl = 'https://jalmanagementsystem.com/api/rider-location';

  /// 🚀 Send rider location to server
  Future<void> sendRiderLocation(RiderLocationModel locationModel) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(locationModel.toJson()),
      );

      if (response.statusCode == 200) {
        debugPrint(
            "✅ Location sent successfully: ${locationModel.latitude}, ${locationModel.longitude}");
      } else {
        debugPrint("❌ Failed to send location: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error sending location: $e");
    }
  }

  /// 🛰️ Production mode — update every 100 meters
  Future<void> startLocationUpdatesByDistance(int riderId, int orderId) async {
    debugPrint("📡 Starting location updates (distance-based)");

    LocationSettings settings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Only update every 100 meters
    );

    Geolocator.getPositionStream(locationSettings: settings).listen((position) {
      if (_lastPosition == null ||
          Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                position.latitude,
                position.longitude,
              ) >=
              100) {
        _lastPosition = position;

        final locationData = RiderLocationModel(
          orderId: orderId,
          riderId: riderId,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        sendRiderLocation(locationData);
      }
    });
  }

  /// ⏱️ Test mode — update every 30 seconds (increased from 5s to avoid rate limiting)
  Future<void> startLocationUpdatesByTime(int riderId, int orderId) async {
    debugPrint("⏱️ Starting location updates (time-based, every 30s)");

    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        _lastPosition = position;

        final locationData = RiderLocationModel(
          orderId: orderId,
          riderId: riderId,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        await sendRiderLocation(locationData);
      } catch (e) {
        debugPrint("❌ Error getting location: $e");
      }
    });
  }

  /// 🛑 Stop location sharing
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    debugPrint("🛑 Location updates stopped");
  }
}
