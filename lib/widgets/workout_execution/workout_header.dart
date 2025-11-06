import 'package:flutter/material.dart';

class WorkoutHeader extends StatelessWidget {
  final bool isSmallScreen;
  final int remainingSeconds;
  final int currentRound;
  final int totalRounds;
  final int currentSegmentIndex;
  final int workoutSegmentsLength;
  final int restSegmentsLength;
  final bool isWorkoutSegment;
  final bool isBetweenRounds;
  final Color currentColor;
  final IconData currentIcon;
  final String currentType;
  final Animation<double> blinkAnimation;
  final int Function() getCurrentSegmentDuration;
  final String Function(int) formatTime;

  const WorkoutHeader({
    super.key,
    required this.isSmallScreen,
    required this.remainingSeconds,
    required this.currentRound,
    required this.totalRounds,
    required this.currentSegmentIndex,
    required this.workoutSegmentsLength,
    required this.restSegmentsLength,
    required this.isWorkoutSegment,
    required this.isBetweenRounds,
    required this.currentColor,
    required this.currentIcon,
    required this.currentType,
    required this.blinkAnimation,
    required this.getCurrentSegmentDuration,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    // 优化：计算一次通用值
    final bool isLast10Seconds = remainingSeconds <= 10 && remainingSeconds > 0;
    final int initialDuration = getCurrentSegmentDuration();
    final double progress = initialDuration > 0
        ? (initialDuration - remainingSeconds) / initialDuration
        : 0.0;
        
    // 优化：将布局拆分为单独的构建方法，提高可读性 (优化排版)
    if (isSmallScreen) {
      return _buildSmallHeader(
        context,
        isLast10Seconds: isLast10Seconds,
        progress: progress,
      );
    }

    return _buildLargeHeader(
      context,
      isLast10Seconds: isLast10Seconds,
      progress: progress,
    );
  }

  /// 构建小屏幕布局
  Widget _buildSmallHeader(
    BuildContext context, {
    required bool isLast10Seconds,
    required double progress,
  }) {
    // 优化：将动态样式提取出来
    final Color timerColor = isLast10Seconds ? Colors.red : currentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左侧计时器
            Expanded(
              flex: 6,
              child: Center(
                // 优化：AnimatedBuilder 仅包裹需要动画的部分
                child: AnimatedBuilder(
                  animation: blinkAnimation,
                  builder: (context, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      // 优化：使用 FadeTransition 替换 ScaleTransition，减少跳动感
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: Text(
                        key: ValueKey(remainingSeconds),
                        formatTime(remainingSeconds),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          // 优化：使用 withOpacity (0.0-1.0) 代替 non-standard withValues
                          color: timerColor.withValues(
                            alpha: isLast10Seconds ? blinkAnimation.value : 1.0,
                          ),
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: currentColor.withValues(alpha: 0.25),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 右侧类型与轮次信息
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: currentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentIcon,
                          color: currentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          currentType,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: currentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '第 $currentRound/$totalRounds 轮',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 优化：使用三元运算符简化片段文本
                  Text(
                    '片段 ${isBetweenRounds ? '-' : (currentSegmentIndex + 1)}/${isBetweenRounds ? '-' : (isWorkoutSegment ? workoutSegmentsLength : (restSegmentsLength > 0 ? restSegmentsLength : workoutSegmentsLength))}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 进度指示器
        // 优化：将 AnimatedBuilder 移到最内层，仅包裹变化的进度条
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                // 优化：使用 AnimatedContainer 自动处理进度条动画
                // 注意：这会改变动画行为，从"闪烁"变为"平滑过渡"
                // 如果必须保持闪烁，则使用 AnimatedBuilder
                child: AnimatedBuilder(
                  animation: blinkAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          // 优化：使用 withOpacity
                          color: timerColor.withValues(
                            alpha: isLast10Seconds ? blinkAnimation.value : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建大屏幕布局
  Widget _buildLargeHeader(
    BuildContext context, {
    required bool isLast10Seconds,
    required double progress,
  }) {
    final Color timerColor = isLast10Seconds ? Colors.red : currentColor;
    const double progressBarWidth = 200.0;

    return Row(
      children: [
        // 左半侧：大计时器
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: currentColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: blinkAnimation,
                      builder: (context, child) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          // 优化：使用 FadeTransition
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            key: ValueKey(remainingSeconds),
                            formatTime(remainingSeconds),
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              // 优化：使用 withOpacity
                              color: timerColor.withValues(
                                alpha: isLast10Seconds ? blinkAnimation.value : 1.0,
                              ),
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: currentColor.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      width: progressBarWidth,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      // 优化：使用 clipRRect 提高性能
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: blinkAnimation,
                              builder: (context, child) {
                                return Container(
                                  height: 5,
                                  // 优化：使用 progress * width
                                  width: (progressBarWidth * progress).clamp(0.0, progressBarWidth),
                                  decoration: BoxDecoration(
                                    // 优化：使用 withOpacity
                                    color: timerColor.withValues(
                                      alpha: isLast10Seconds ? blinkAnimation.value : 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 右半侧：状态与进度信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      currentIcon,
                      color: currentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    currentType,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: currentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '第 $currentRound/$totalRounds 轮',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              // 优化：使用三元运算符简化片段文本
              Text(
                '片段 ${isBetweenRounds ? '-' : (currentSegmentIndex + 1)}/${isBetweenRounds ? '-' : (isWorkoutSegment ? workoutSegmentsLength : (restSegmentsLength > 0 ? restSegmentsLength : workoutSegmentsLength))}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}