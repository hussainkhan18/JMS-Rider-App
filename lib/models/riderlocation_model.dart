class RiderLocationModel {
  final int orderId;
  final int riderId;
  final double latitude;
  final double longitude;

  RiderLocationModel({
    required this.orderId,
    required this.riderId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "rider_id": riderId,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
