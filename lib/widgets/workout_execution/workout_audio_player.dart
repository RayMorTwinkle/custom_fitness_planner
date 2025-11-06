import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// 训练音频播放器
/// 负责在训练片段和休息片段结束前3秒播放嘀嗒声
class WorkoutAudioPlayer {
  static final WorkoutAudioPlayer _instance = WorkoutAudioPlayer._internal();
  
  factory WorkoutAudioPlayer() => _instance;
  
  WorkoutAudioPlayer._internal() {
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }
  
  late final AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPreloaded = false; // 音频是否已预加载
  
  /// 初始化音频播放器
  Future<void> _initAudioPlayer() async {
    try {
      // 设置音频播放模式
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(0.7); // 设置适中音量
      _isInitialized = true;
    } catch (e) {
      debugPrint('音频播放器初始化失败: $e');
    }
  }
  
  /// 预加载音频文件
  /// 在训练开始前调用，提前加载音频到内存中
  Future<void> preloadAudio() async {
    if (!_isInitialized || _isPreloaded) {
      return;
    }
    
    try {
      // 预加载音频文件到内存中
      await _audioPlayer.setSource(AssetSource('sounds/Tick.mp3'));
      _isPreloaded = true;
      debugPrint('音频文件预加载完成');
    } catch (e) {
      debugPrint('音频预加载失败: $e');
    }
  }
  
  /// 播放嘀嗒声
  /// 在片段结束前3秒的每一秒调用一次，播放半秒钟后自动停止
  Future<void> playTickSound() async {
    if (!_isInitialized || _isPlaying) {
      return; // 如果未初始化或正在播放，则跳过
    }
    
    try {
      _isPlaying = true;
      
      // 如果音频已预加载，使用seek到开始位置并播放；否则重新设置源
      if (_isPreloaded) {
        // 使用seek到开始位置，确保每次播放都从头开始
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
      } else {
        // 播放音频文件
        await _audioPlayer.play(
          AssetSource('sounds/Tick.mp3'),
          volume: 0.7, // 设置音量
          mode: PlayerMode.lowLatency, // 低延迟模式
        );
      }
      
      // 播放半秒钟后自动停止，防止音频冲突
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (_isPlaying) {
          await _audioPlayer.stop();
          _isPlaying = false;
        }
      });
      
      // 监听播放完成事件（备用）
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
      
    } catch (e) {
      debugPrint('播放嘀嗒声失败: $e');
      _isPlaying = false;
    }
  }
  
  /// 停止播放
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('停止音频播放失败: $e');
    }
  }
  
  /// 释放音频资源（但不销毁播放器）
  /// 在训练结束时调用，释放预加载的音频资源
  Future<void> releaseAudio() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
      _isPreloaded = false;
      _isPlaying = false;
      debugPrint('音频资源已释放');
    } catch (e) {
      debugPrint('释放音频资源失败: $e');
    }
  }
  
  /// 释放所有资源
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isInitialized = false;
      _isPlaying = false;
      _isPreloaded = false;
    } catch (e) {
      debugPrint('释放音频播放器失败: $e');
    }
  }
  
  /// 检查是否正在播放
  bool get isPlaying => _isPlaying;
  
  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 检查音频是否已预加载
  bool get isPreloaded => _isPreloaded;
}

/// 音频播放器管理器
/// 提供便捷的方法来管理音频播放
class WorkoutAudioManager {
  static final WorkoutAudioManager _instance = WorkoutAudioManager._internal();
  
  factory WorkoutAudioManager() => _instance;
  
  WorkoutAudioManager._internal() {
    _audioPlayer = WorkoutAudioPlayer();
  }
  
  late final WorkoutAudioPlayer _audioPlayer;
  int _lastPlayedSecond = -1; // 记录上次播放的秒数，避免重复播放
  bool _isAudioPreloaded = false; // 音频是否已预加载
  
  /// 预加载音频文件
  /// 在训练开始前调用，提前加载音频到内存中
  Future<void> preloadAudio() async {
    if (_isAudioPreloaded) {
      return;
    }
    
    try {
      await _audioPlayer.preloadAudio();
      _isAudioPreloaded = true;
      debugPrint('音频管理器：音频预加载完成');
    } catch (e) {
      debugPrint('音频管理器：音频预加载失败: $e');
    }
  }
  
  /// 处理计时器滴答事件
  /// 在片段结束前3、2、1、0秒都播放嘀嗒声
  void handleTimerTick(int remainingSeconds, int segmentDuration) {
    // 在倒数3、2、1、0秒都播放嘀嗒声
    if (remainingSeconds <= 3) {
      // 避免在同一秒内重复播放
      if (_lastPlayedSecond != remainingSeconds) {
        _lastPlayedSecond = remainingSeconds;
        _audioPlayer.playTickSound();
      }
    } else {
      // 重置播放记录
      _lastPlayedSecond = -1;
    }
  }
  
  /// 停止所有音频播放
  Future<void> stopAll() async {
    await _audioPlayer.stop();
    _lastPlayedSecond = -1;
  }
  
  /// 释放音频资源（但不销毁播放器）
  /// 在训练结束时调用，释放预加载的音频资源
  Future<void> releaseAudio() async {
    try {
      await _audioPlayer.releaseAudio();
      _isAudioPreloaded = false;
      _lastPlayedSecond = -1;
      debugPrint('音频管理器：音频资源已释放');
    } catch (e) {
      debugPrint('音频管理器：释放音频资源失败: $e');
    }
  }
  
  /// 释放所有资源
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _lastPlayedSecond = -1;
    _isAudioPreloaded = false;
  }
  
  /// 获取音频播放器状态
  bool get isPlaying => _audioPlayer.isPlaying;
  bool get isInitialized => _audioPlayer.isInitialized;
  bool get isAudioPreloaded => _isAudioPreloaded;
}