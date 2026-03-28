class HelpVideoResponse {
  final String status;
  final String roleType;
  final int count;
  final List<HelpVideo> data;

  HelpVideoResponse({
    required this.status,
    required this.roleType,
    required this.count,
    required this.data,
  });

  factory HelpVideoResponse.fromJson(Map<String, dynamic> json) {
    return HelpVideoResponse(
      status: json['status'] ?? '',
      roleType: json['role_type'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => HelpVideo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HelpVideo {
  final int id;
  final String title;
  final String description;
  final String image;
  final String video;

  HelpVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.video,
  });

  factory HelpVideo.fromJson(Map<String, dynamic> json) {
    return HelpVideo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      video: json['video'] ?? '',
    );
  }
}
