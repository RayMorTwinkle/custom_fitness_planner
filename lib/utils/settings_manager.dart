import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _segmentDurationKey = 'segmentDuration';
  static const String _restDurationKey = 'restDuration';
  
  // 默认值
  static const double defaultSegmentDuration = 45.0;
  static const double defaultRestDuration = 20.0;
  
  // 获取片段时长
  static Future<double> getSegmentDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_segmentDurationKey) ?? defaultSegmentDuration;
  }
  
  // 获取休息时长
  static Future<double> getRestDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_restDurationKey) ?? defaultRestDuration;
  }
  
  // 设置片段时长
  static Future<void> setSegmentDuration(double duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_segmentDurationKey, duration);
  }
  
  // 设置休息时长
  static Future<void> setRestDuration(double duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_restDurationKey, duration);
  }
}