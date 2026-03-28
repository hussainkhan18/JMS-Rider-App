import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:jms/models/help_video_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<http.Response> addSale(Map<String, dynamic> orderData) async {
    final url = Uri.parse('$baseUrl/api/add_sale');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> getProducts(String refrelCode) async {
    final url = Uri.parse('$baseUrl/items/$refrelCode');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> getBanners(String refrelCode) async {
    final url = Uri.parse('$baseUrl/banners/$refrelCode');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data));
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<List<HelpVideo>> getHelpVideos() async {
    final url = Uri.parse('$baseUrl/api/guides/rider');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Help videos response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return HelpVideoResponse.fromJson(data).data;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch help videos');
        }
      } else {
        throw Exception('Failed to load help videos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getHelpVideos: $e');
      throw Exception('Error fetching help videos: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data));
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<dynamic> getOrder(String userId) async {
    final url = Uri.parse('$baseUrl/api/get_order/$userId');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> sendLocationToServer(int riderId, double lat, double lng) async {
    try {
      await http.post(
        Uri.parse("https://jalmanagementsystem.com/api/rider-location"),
        body: {
          "rider_id": riderId.toString(),
          "latitude": lat.toString(),
          "longitude": lng.toString(),
        },
      );
    } catch (e) {
      print("Error sending location: $e");
    }
  }

  Future<double> calculateDistance(
      double startLat, double startLng, double endLat, double endLng) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // dynamic _processResponse(http.Response response) {
  //   final statusCode = response.statusCode;
  //   final body = response.body;

  //   print('Response Status Code: $statusCode');
  //   print('Response Body: $body');

  //   if (statusCode >= 200 && statusCode < 300) {
  //     return json.decode(body);
  //   } else {
  //     try {
  //       final responseData = json.decode(body);
  //       if (responseData is Map<String, dynamic> &&
  //           responseData.containsKey('errors')) {
  //         final errors = responseData['errors'] as Map<String, dynamic>;
  //         throw Exception(
  //             errors.entries.map((e) => '${e.key}: ${e.value}').join('\n'));
  //       }
  //       throw Exception('Error: $statusCode\n$body');
  //     } catch (e) {
  //       // Return a generic error message if the response format is unexpected
  //       return 'An error occurred: $e';
  //     }
  //   }
  // }
}
