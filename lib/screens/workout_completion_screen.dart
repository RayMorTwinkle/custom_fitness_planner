import 'package:flutter/material.dart';
import 'package:flowfit/models/fitness_plan.dart';

// 优化：
// 1. 转换为 StatefulWidget 以添加加载动画，提升用户体验。
// 2. 使用 SingleTickerProviderStateMixin 来管理动画控制器。
// 3. 为统计卡片添加交错（staggered）的淡入和上移动画。
// 4. 为底部按钮添加淡入动画。
// 5. 使用 ListView.builder 来构建卡片列表，以便于应用动画。
// 6. 在所有适用的地方添加 `const` 关键字，以优化 build 性能。

class WorkoutCompletionScreen extends StatefulWidget {
  final FitnessPlan plan;
  final Duration totalDuration;
  final int totalRounds;
  final int totalWorkoutSegments;

  const WorkoutCompletionScreen({
    super.key,
    required this.plan,
    required this.totalDuration,
    required this.totalRounds,
    required this.totalWorkoutSegments,
  });

  @override
  State<WorkoutCompletionScreen> createState() => _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState extends State<WorkoutCompletionScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;
  
  // 3个统计卡 + 1个详情卡
  final int _numAnimatedItems = 4;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // 动画总时长
    );

    _cardAnimations = List.generate(
      _numAnimatedItems,
      (index) {
        // 交错动画，每个卡片延迟 150ms 开始
        final startTime = (index * 150) / 1200.0;
        // 每个卡片动画持续 600ms
        final endTime = (startTime + 0.5).clamp(0.0, 1.0);
        
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              startTime,
              endTime,
              curve: Curves.easeOutCubic,
            ),
          ),
        );
      },
    );

    // 启动动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours小时$minutes分$seconds秒';
    } else if (minutes > 0) {
      return '$minutes分$seconds秒';
    } else {
      return '$seconds秒';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            
            // 响应式断点
            final bool isSmallScreen = screenWidth < 600;
            final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
            
            // 响应式尺寸计算
            final double topPadding = isSmallScreen ? 30.0 : isMediumScreen ? 40.0 : 50.0;
            final double horizontalPadding = isSmallScreen ? 16.0 : isMediumScreen ? 20.0 : 24.0;
            final double iconSize = isSmallScreen ? 60.0 : isMediumScreen ? 70.0 : 80.0;
            final double titleFontSize = isSmallScreen ? 28.0 : isMediumScreen ? 32.0 : 36.0;
            final double subtitleFontSize = isSmallScreen ? 16.0 : isMediumScreen ? 18.0 : 20.0;
            final double contentPadding = isSmallScreen ? 16.0 : isMediumScreen ? 20.0 : 24.0;
            final double spacingValue = isSmallScreen ? 12.0 : isMediumScreen ? 14.0 : 16.0;
            final double buttonPadding = isSmallScreen ? 12.0 : isMediumScreen ? 14.0 : 16.0;

            // 优化：将卡片构建逻辑放入 LayoutBuilder 中，以确保响应式参数正确传递
            final List<Widget> cardItems = [
              _buildStatCard(
                icon: Icons.timer,
                title: '总训练时长',
                value: _formatDuration(widget.totalDuration),
                color: Colors.blue,
                isSmallScreen: isSmallScreen,
              ),
              _buildStatCard(
                icon: Icons.repeat,
                title: '完成轮数',
                value: '${widget.totalRounds} 轮',
                color: Colors.orange,
                isSmallScreen: isSmallScreen,
              ),
              _buildStatCard(
                icon: Icons.fitness_center,
                title: '训练片段总数',
                value: '${widget.totalWorkoutSegments} 个',
                color: Colors.green,
                isSmallScreen: isSmallScreen,
              ),
              _buildPlanInfoCard(
                plan: widget.plan,
                isSmallScreen: isSmallScreen, 
                spacingValue: spacingValue, 
                contentPadding: contentPadding
              ),
            ];

            return Column(
              children: [
                // 顶部庆祝区域
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: topPadding, horizontal: horizontalPadding),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withAlpha(77), // 0.3 * 255
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      SizedBox(height: spacingValue),
                      Text(
                        '训练完成！',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withAlpha(77), // 0.3 * 255
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacingValue / 2),
                      Text(
                        widget.plan.title,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // 统计信息卡片 - 优化为 ListView.builder 以应用动画
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(contentPadding),
                    itemCount: cardItems.length,
                    itemBuilder: (context, index) {
                      // 应用动画
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          final animationValue = _cardAnimations[index].value;
                          // 结合淡入和向上平移
                          return FadeTransition(
                            opacity: _cardAnimations[index], // 使用 animation 作为 opacity
                            child: Transform.translate(
                              offset: Offset(0.0, 50 * (1.0 - animationValue)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          // 在卡片间添加间距
                          padding: EdgeInsets.only(bottom: index == cardItems.length - 1 ? 0 : spacingValue),
                          child: cardItems[index],
                        ),
                      );
                    },
                  ),
                ),

                // 底部按钮 - 添加淡入动画
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      // 在动画的最后 20% (Interval(0.8, 1.0)) 淡入按钮
                      opacity: CurvedAnimation(
                        parent: _animationController, 
                        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                      ),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 直接返回到应用根页面
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('返回主页'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: buttonPadding),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 辅助方法：构建统计卡片
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    final double cardPadding = isSmallScreen ? 16.0 : 20.0;
    final double iconSize = isSmallScreen ? 24.0 : 32.0;
    final double spacingValue = isSmallScreen ? 12.0 : 16.0;
    final double titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final double valueFontSize = isSmallScreen ? 18.0 : 24.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 * 255
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(cardPadding - 4),
            decoration: BoxDecoration(
              color: color.withAlpha(26), // 0.1 * 255
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
          SizedBox(width: spacingValue),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    // fontSize 动态计算，不能 const
                    fontSize: titleFontSize, 
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 辅助方法：构建计划详情卡片
  Widget _buildPlanInfoCard({
    required FitnessPlan plan,
    required bool isSmallScreen,
    required double spacingValue,
    required double contentPadding,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 * 255
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '训练计划详情',
            style: TextStyle(
              fontSize: isSmallScreen ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: spacingValue),
          _buildPlanInfoRow('计划时长', plan.formattedDuration, isSmallScreen),
          _buildPlanInfoRow('总轮数', '${plan.totalRounds} 轮', isSmallScreen),
          _buildPlanInfoRow('训练片段', '${plan.workoutSegments.length} 个', isSmallScreen),
          _buildPlanInfoRow('休息片段', '${plan.restSegments.length} 个', isSmallScreen),
        ],
      ),
    );
  }
  
  // 辅助方法：构建计划详情行
  Widget _buildPlanInfoRow(String label, String value, bool isSmallScreen) {
    final double fontSize = isSmallScreen ? 14.0 : 16.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}