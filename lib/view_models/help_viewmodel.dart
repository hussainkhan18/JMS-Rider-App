import 'package:flutter/foundation.dart';
import 'package:jms/models/help_video_model.dart';
import 'package:jms/services/api_service.dart';

enum HelpState { initial, loading, loaded, error }

class HelpViewModel extends ChangeNotifier {
  final ApiService _apiService;

  HelpViewModel(this._apiService);

  List<HelpVideo> _videos = [];
  HelpState _state = HelpState.initial;
  String? _error;

  List<HelpVideo> get videos => _videos;
  HelpState get state => _state;
  String? get error => _error;

  Future<void> fetchHelpVideos() async {
    if (_state == HelpState.loading) return;

    _setState(HelpState.loading);

    try {
      final videos = await _apiService.getHelpVideos();
      _videos = videos;
      _setState(HelpState.loaded);
    } catch (e) {
      _error = e.toString();
      _setState(HelpState.error);
    }
  }

  void _setState(HelpState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
