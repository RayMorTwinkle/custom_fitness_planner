import 'package:flutter/material.dart';
import '../models/fitness_plan.dart';
import '../models/workout_segment.dart';
import '../screens/workout_completion_screen.dart';
import 'dart:async';
import '../widgets/workout_execution/workout_header.dart';
import '../widgets/workout_execution/workout_content.dart';
import '../widgets/workout_execution/workout_controls.dart';
import '../widgets/workout_execution/workout_audio_player.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final FitnessPlan plan;

  const WorkoutExecutionScreen({
    super.key,
    required this.plan,
  });

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> with TickerProviderStateMixin {
  // 状态变量
  int _currentRound = 1;
  int _currentSegmentIndex = 0;
  bool _isWorkoutSegment = true;
  bool _isBetweenRounds = false; // 是否在轮间休息
  Timer? _timer;
  WorkoutSegment? _nextWorkoutSegment;
  
  // --- 性能优化 1: ValueNotifiers ---
  // 将高频更新的状态（计时器）与低频更新的状态（片段切换）分离。
  // _remainingSecondsNotifier 用于驱动UI上的倒计时显示。
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier<int>(0);
  // _totalDurationNotifier 用于累计总时间。
  final ValueNotifier<Duration> _totalDurationNotifier = ValueNotifier<Duration>(Duration.zero);
  
  // 闪烁动画控制器
  late AnimationController _blinkAnimationController;
  late Animation<double> _blinkAnimation;
  
  // 音频管理器
  late final WorkoutAudioManager _audioManager;

  @override
  void initState() {
    super.initState();
    
    // 初始化闪烁动画控制器
    _blinkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 初始化音频管理器
    _audioManager = WorkoutAudioManager();
    
    // 预加载音频文件，减少播放延迟
    _preloadAudio();
    
    _startCurrentSegment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blinkAnimationController.dispose();
    // --- 性能优化 2: 释放 Notifiers ---
    _remainingSecondsNotifier.dispose();
    _totalDurationNotifier.dispose();
    // 释放音频管理器
    _audioManager.dispose();
    super.dispose();
  }

  void _startCurrentSegment() {
    _timer?.cancel();
    
    int duration;
    if (_isWorkoutSegment) {
      final segment = widget.plan.workoutSegments[_currentSegmentIndex];
      duration = segment.duration;
      _nextWorkoutSegment = null;
    } else {
      // 休息片段
      final restSegmentIndex = _currentSegmentIndex < widget.plan.restSegments.length 
          ? _currentSegmentIndex 
          : widget.plan.restSegments.length - 1;
      final segment = widget.plan.restSegments[restSegmentIndex];
      duration = segment.duration;
      
      // 设置下一个训练片段（用于休息时间显示）
      final nextIndex = _currentSegmentIndex + 1;
      if (nextIndex < widget.plan.workoutSegments.length) {
        _nextWorkoutSegment = widget.plan.workoutSegments[nextIndex];
      } else {
        _nextWorkoutSegment = null;
      }
    }
    
    // 更新 Notifier 来驱动 UI
    _remainingSecondsNotifier.value = duration;
    _startTimer();
  }

  int _getCurrentSegmentDuration() {
    if (_isBetweenRounds) {
      return widget.plan.restBetweenRounds;
    } else if (_isWorkoutSegment) {
      return widget.plan.workoutSegments[_currentSegmentIndex].duration;
    } else {
      final restSegmentIndex = _currentSegmentIndex < widget.plan.restSegments.length 
          ? _currentSegmentIndex 
          : widget.plan.restSegments.length - 1;
      return widget.plan.restSegments[restSegmentIndex].duration;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // --- 性能优化 3: 移除高频 setState ---
      // Timer 内部不再调用 setState。
      // 而是直接更新 ValueNotifiers。
      // 只有 UI 中监听了这些 Notifiers 的部分会重建。
      if (_remainingSecondsNotifier.value > 0) {
        _remainingSecondsNotifier.value--;
        _totalDurationNotifier.value += const Duration(seconds: 1);
           
        // 音频播放逻辑：在片段结束前3秒播放嘀嗒声
        if (!_isBetweenRounds) { // 只在训练片段和休息片段播放，轮间休息不播放
          final int segmentDuration = _getCurrentSegmentDuration();
          _audioManager.handleTimerTick(_remainingSecondsNotifier.value, segmentDuration);
        }
           
        // 动画逻辑
        if (_remainingSecondsNotifier.value <= 10 && _remainingSecondsNotifier.value > 0) {
          if (!_blinkAnimationController.isAnimating) {
            _blinkAnimationController.repeat(reverse: true);
          }
        } else {
          _blinkAnimationController.stop();
          _blinkAnimationController.value = 1.0;
        }
      } else {
        // --- 性能优化 4: 仅在状态切换时调用 setState ---
        // 计时器结束，需要切换到下一片段或下一轮。
        // 这是一个低频的状态改变，此时才调用 setState 来重建逻辑。
        _timer?.cancel();
        _blinkAnimationController.stop();
        _blinkAnimationController.value = 1.0;
        
        // 停止所有音频播放
        _audioManager.stopAll();
        
        // 在 setState 中执行状态切换逻辑
        setState(() {
          if (_isBetweenRounds) {
            _endBetweenRoundsRest();
          } else {
            _nextSegment();
          }
        });
      }
    });
  }

  // _nextSegment, _nextRound, _endBetweenRoundsRest 都是低频状态改变，
  // 它们保留在 setState 中是正确的。

  void _nextSegment() {
    _timer?.cancel();
    // setState 保持不变，因为这是核心逻辑状态的变更
    setState(() {
      if (_isWorkoutSegment) {
        if (_currentSegmentIndex + 1 < widget.plan.workoutSegments.length) {
          _isWorkoutSegment = false;
        } else {
          _nextRound();
          return;
        }
      } else {
        _isWorkoutSegment = true;
        _currentSegmentIndex++;
        if (_currentSegmentIndex >= widget.plan.workoutSegments.length) {
          _nextRound();
          return;
        }
      }
      _startCurrentSegment();
    });
  }

  void _nextRound() {
    setState(() {
      if (_currentRound < widget.plan.totalRounds) {
        _isBetweenRounds = true;
        // 更新 Notifier
        _remainingSecondsNotifier.value = widget.plan.restBetweenRounds;
        _startTimer();
      } else {
        _timer?.cancel();
        _showCompletionDialog();
      }
    });
  }

  void _endBetweenRoundsRest() {
    setState(() {
      _isBetweenRounds = false;
      _currentRound++;
      _currentSegmentIndex = 0;
      _isWorkoutSegment = true;
      _startCurrentSegment();
    });
  }

  /// 预加载音频文件
  Future<void> _preloadAudio() async {
    try {
      await _audioManager.preloadAudio();
    } catch (e) {
      debugPrint('音频预加载失败: $e');
    }
  }

  void _showCompletionDialog() {
    // 在显示完成对话框前释放音频资源
    _releaseAudio();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => WorkoutCompletionScreen(
              plan: widget.plan,
              // 从 Notifier 读取最终值
              totalDuration: _totalDurationNotifier.value,
              totalRounds: widget.plan.totalRounds,
              totalWorkoutSegments: widget.plan.workoutSegments.length * widget.plan.totalRounds,
            ),
          ),
          (route) => false,
        );
      }
    });
  }
  
  /// 释放音频资源
  Future<void> _releaseAudio() async {
    try {
      await _audioManager.releaseAudio();
    } catch (e) {
      debugPrint('音频资源释放失败: $e');
    }
  }

  void _pauseResume() {
    // 暂停/恢复是低频操作，使用 setState 是正确的
    setState(() {
      if (_timer?.isActive == true) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  void _skipSegment() {
    // 跳过是低频操作，使用 setState 是正确的
    setState(() {
      if (_isBetweenRounds) {
        _endBetweenRoundsRest();
      } else {
        _nextSegment();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------------
    // 核心逻辑: build 方法现在只在低频状态（如切换片段、暂停）时运行。
    // 它不再每秒都运行，从而极大提高了性能。
    // ---------------------------------------------------------------

    // 状态计算（低频，保持在 build 方法中）
    final dynamic currentSegment = _isWorkoutSegment 
        ? (_currentSegmentIndex < widget.plan.workoutSegments.length 
            ? widget.plan.workoutSegments[_currentSegmentIndex] 
            : null)
        : (_currentSegmentIndex < widget.plan.restSegments.length 
            ? widget.plan.restSegments[_currentSegmentIndex] 
            : null);

    Color currentColor;
    IconData currentIcon;
    String currentType;

    if (_isBetweenRounds) {
      currentColor = const Color(0xFF9C27B0);
      currentIcon = Icons.autorenew;
      currentType = '轮间休息';
    } else if (_isWorkoutSegment) {
      currentColor = const Color(0xFF4CAF50);
      currentIcon = Icons.fitness_center;
      currentType = '训练片段';
    } else {
      currentColor = const Color(0xFFFF9800);
      currentIcon = Icons.timer;
      currentType = '休息片段';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title, style: TextStyle(color: Colors.white)),
        backgroundColor: currentColor,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 响应式布局计算（低频，保持在 build 方法中）
          final screenWidth = constraints.maxWidth;
          final bool isSmallScreen = screenWidth < 600;
          final bool isWideLayout = screenWidth >= 800;
          final bool isMediumScreen = !isSmallScreen && !isWideLayout;
          final bool isLargeScreen = isWideLayout;
          
          final double paddingValue = isSmallScreen ? 8.0 : isMediumScreen ? 12.0 : 12.0;
          final double verticalPadding = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 14.0;
          
          return Column(
            children: [
              // 顶部信息区域
              Container(
                padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: paddingValue),
                margin: EdgeInsets.only(bottom: 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      currentColor.withValues(alpha: 0.1),
                      currentColor.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: currentColor.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                ),
                // --- 性能优化 5: 使用 ValueListenableBuilder ---
                // 仅包裹需要高频更新的 WorkoutHeader。
                // 只有 _remainingSecondsNotifier 变化时，此 builder 才会重建。
                child: ValueListenableBuilder<int>(
                  valueListenable: _remainingSecondsNotifier,
                  builder: (context, remainingSecondsValue, child) {
                    // 动画现在在稳定的 Widget 树中运行，不会闪烁
                    //（因为 WorkoutHeader 的父级不再每秒重建）。
                    return WorkoutHeader(
                      isSmallScreen: isSmallScreen,
                      remainingSeconds: remainingSecondsValue, // 传递来自 Notifier 的值
                      currentRound: _currentRound,
                      totalRounds: widget.plan.totalRounds,
                      currentSegmentIndex: _currentSegmentIndex,
                      workoutSegmentsLength: widget.plan.workoutSegments.length,
                      restSegmentsLength: widget.plan.restSegments.length,
                      isWorkoutSegment: _isWorkoutSegment,
                      isBetweenRounds: _isBetweenRounds,
                      currentColor: currentColor,
                      currentIcon: currentIcon,
                      currentType: currentType,
                      blinkAnimation: _blinkAnimation, // 动画控制器状态被保留
                      getCurrentSegmentDuration: _getCurrentSegmentDuration,
                      formatTime: _formatTime,
                    );
                  },
                ),
              ),

              // 片段标题和描述
              Expanded(
                child: Stack(
                  children: [
                    // 内容区域填充
                    Positioned.fill(
                      // --- 性能优化 6: 使用 ValueListenableBuilder ---
                      // 同样，仅包裹需要高频更新的 WorkoutContent。
                      child: ValueListenableBuilder<int>(
                        valueListenable: _remainingSecondsNotifier,
                        builder: (context, remainingSecondsValue, child) {
                          return WorkoutContent(
                            isSmallScreen: isSmallScreen,
                            isLargeScreen: isLargeScreen,
                            isBetweenRounds: _isBetweenRounds,
                            isWorkoutSegment: _isWorkoutSegment,
                            currentRound: _currentRound,
                            restBetweenRounds: widget.plan.restBetweenRounds,
                            remainingSeconds: remainingSecondsValue, // 传递来自 Notifier 的值
                            currentSegment: currentSegment,
                            nextWorkoutSegment: _nextWorkoutSegment,
                            workoutSegments: widget.plan.workoutSegments,
                          );
                        },
                      ),
                    ),

                    // 浮动控制按钮
                    // WorkoutControls 依赖于 _timer?.isActive，
                    // 它在 _pauseResume (低频) 中通过 setState 更新，
                    // 因此它不需要 ValueListenableBuilder。
                    Align(
                      alignment: isSmallScreen ? Alignment.bottomCenter : Alignment.bottomRight,
                      child: SafeArea(
                        minimum: isSmallScreen 
                            ? const EdgeInsets.only(bottom: 8, right: 8, left: 8)
                            : const EdgeInsets.only(bottom: 16, right: 24, left: 8),
                        child: Container(
                          constraints: isSmallScreen 
                              ? null 
                              : const BoxConstraints(maxWidth: 380),
                          child: WorkoutControls(
                            isSmallScreen: isSmallScreen,
                            isTimerActive: _timer?.isActive == true,
                            onPauseResume: _pauseResume,
                            onSkipSegment: _skipSegment,
                            onExit: () {
                              // 退出前释放音频资源
                              _releaseAudio();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
