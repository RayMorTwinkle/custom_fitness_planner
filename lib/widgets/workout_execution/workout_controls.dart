import 'package:flutter/material.dart';

class WorkoutControls extends StatelessWidget {
  final bool isSmallScreen;
  final bool isTimerActive;
  final VoidCallback onPauseResume;
  final VoidCallback onSkipSegment;
  final VoidCallback onExit;

  const WorkoutControls({
    super.key,
    required this.isSmallScreen,
    required this.isTimerActive,
    required this.onPauseResume,
    required this.onSkipSegment,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    // 优化：统一定义响应式尺寸，提高可读性
    final double hPadding = isSmallScreen ? 16 : 20;
    final double vPadding = isSmallScreen ? 12 : 14;
    final double iconSize = isSmallScreen ? 18 : 20;
    final double spacing = isSmallScreen ? 8 : 12;

    return Container(
      // 外部容器的内边距，取决于屏幕大小
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? 300 : 380, // 窄屏最大宽度300，宽屏最大宽度380
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            // 1. 暂停/继续 按钮
            Expanded(
              // 优化：AnimatedContainer 仅用于动画背景色和阴影
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isTimerActive ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      // 优化：使用 .withAlpha(128) 代替 .withValues
                      color: (isTimerActive ? Colors.orange : Colors.green)
                          .withAlpha(128),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: onPauseResume,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPadding,
                      vertical: vPadding,
                    ),
                    // 优化：使用 AnimatedSwitcher 为图标和文本添加淡入淡出动画
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Row(
                        // 优化：使用 ValueKey 确保 AnimatedSwitcher 识别内容变化
                        key: ValueKey<bool>(isTimerActive),
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isTimerActive ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTimerActive ? '暂停' : '继续',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),

            // 2. 跳过 按钮
            // 优化：将重复的按钮样式提取到 _buildControlButton 辅助方法
            _buildControlButton(
              onTap: onSkipSegment,
              color: Colors.blue.shade700,
              shadowColor: Colors.blue.withAlpha(128),
              icon: Icons.skip_next,
              text: '跳过',
              hPadding: hPadding,
              vPadding: vPadding,
              iconSize: iconSize,
            ),
            SizedBox(width: spacing),

            // 3. 退出 按钮
            _buildControlButton(
              onTap: onExit,
              color: Colors.red.shade700,
              shadowColor: Colors.red.withAlpha(128),
              icon: Icons.close,
              text: '退出',
              hPadding: hPadding,
              vPadding: vPadding,
              iconSize: iconSize,
            ),
          ],
        ),
      ),
    );
  }

  /// 优化：提取静态按钮的构建逻辑，减少代码重复（优化排版）
  Widget _buildControlButton({
    required VoidCallback onTap,
    required Color color,
    required Color shadowColor,
    required IconData icon,
    required String text,
    required double hPadding,
    required double vPadding,
    required double iconSize,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: vPadding,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}