import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/workout_segment.dart';

class WorkoutContent extends StatelessWidget {
  final bool isSmallScreen;
  final bool isLargeScreen;
  final bool isBetweenRounds;
  final bool isWorkoutSegment;
  final int currentRound;
  final int restBetweenRounds;
  final int remainingSeconds;
  
  // --- 修正: 恢复为 dynamic ---
  // 这个变量需要能够持有 WorkoutSegment 或 RestSegment
  final dynamic currentSegment; 
  final WorkoutSegment? nextWorkoutSegment;
  final List<WorkoutSegment> workoutSegments;

  const WorkoutContent({
    super.key,
    required this.isSmallScreen,
    required this.isLargeScreen,
    required this.isBetweenRounds,
    required this.isWorkoutSegment,
    required this.currentRound,
    required this.restBetweenRounds,
    required this.remainingSeconds,
    required this.currentSegment,
    required this.nextWorkoutSegment,
    required this.workoutSegments,
  });

  // --- 优化 2: 提取通用逻辑和排版 ---
  // 将 Widget 构建逻辑提取到私有方法中，使 build 方法更清晰。
  // 使用 Theme.of(context) 统一样式。

  /// 构建标题 Widget，并使用 AnimatedSwitcher 实现平滑过渡
  Widget _buildTitle(BuildContext context, String titleText) {
    // 使用主题样式
    final titleStyle = isLargeScreen 
      ? Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
      : Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        // --- 优化 3: 使用 Key ---
        // 为 AnimatedSwitcher 的子项提供唯一的 Key，以确保动画正确触发
        key: ValueKey<String>(titleText),
        titleText,
        style: titleStyle,
      ),
    );
  }

  /// 构建下一个动作提示（仅休息时）
  Widget _buildNextActionHeader(BuildContext context) {
    if (isWorkoutSegment || nextWorkoutSegment == null) {
      return const SizedBox.shrink();
    }

    final headerStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        );
    final titleStyle = Theme.of(context).textTheme.headlineSmall;

    // 使用 AnimatedSwitcher 平滑显示和隐藏
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          // 使用 SizeTransition 避免布局抖动
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
      child: Column(
        key: ValueKey<String?>(nextWorkoutSegment?.title),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('下一个动作：', style: headerStyle),
          const SizedBox(height: 8),
          Text(nextWorkoutSegment!.title, style: titleStyle),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// 构建图片显示 Widget
  Widget _buildImageWidget(String? imagePath) {
    // --- 优化 4: 动画和排版 ---
    // 使用 AnimatedSwitcher 为图片的出现、消失和切换提供平滑的淡入淡出效果
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        // 使用 Key 确保 AnimatedSwitcher 识别内容变化
        key: ValueKey<String?>(imagePath),
        width: double.infinity,
        // 响应式高度
        height: isLargeScreen ? 400 : (isSmallScreen ? 240 : 320),
        decoration: BoxDecoration(
          color: Colors.grey.shade100, // 占位背景色
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        // imagePath 为 null 时显示占位符
        child: imagePath == null
            ? Center(
                child: Text(
                  '无图片',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14), // 略小于边框
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  // --- 性能优化 5: 优化 Error Builder ---
                  // Error Builder 保持简洁
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error_outline, color: Colors.grey, size: 48),
                          SizedBox(height: 8),
                          Text(
                            '图片加载失败',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  /// 构建描述区域（动作说明或轮间休息说明）
  Widget _buildDescriptionSection(BuildContext context) {
    String? title;
    String? description;
    Color? titleColor;

    if (isBetweenRounds) {
      title = '轮间休息说明：';
      description = '准备进入下一轮训练，休息结束自动开始';
      titleColor = Colors.purple;
    } 
    // --- 修正: 恢复运行时类型检查 'is WorkoutSegment' ---
    else if (isWorkoutSegment && currentSegment != null && currentSegment is WorkoutSegment && currentSegment.description.isNotEmpty) {
      title = '动作说明：';
      description = currentSegment.description;
      titleColor = Colors.blue;
    }
    // 休息片段 (isWorkoutSegment == false) 没有描述

    // 如果没有说明，则不显示
    if (description == null) {
      return const SizedBox.shrink();
    }

    // 同样使用 AnimatedSwitcher 平滑过渡
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
      child: Card(
        key: ValueKey<String>(description),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建片段信息卡片（显示剩余时间）
  Widget _buildInfoCard(BuildContext context) {
    // --- 优化 7: 性能 ---
    // 这个卡片的内容（剩余秒数）是高频更新的。
    // 在上层 (WorkoutExecutionScreen)，remainingSeconds 已经
    // 通过 ValueListenableBuilder 传递下来了。
    // WorkoutContent 会在上层重建，所以这里不需要额外的 Builder。
    
    // 我们使用 AnimatedSwitcher 来平滑数字的变化
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '片段信息：',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                // 使用 AnimatedSwitcher 平滑更新时间
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    '时长：$remainingSeconds 秒',
                    key: ValueKey<int>(remainingSeconds),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 优化 8: 简化逻辑 ---
    // 统一图片路径逻辑
    String? imagePath;
    if (isBetweenRounds) {
      if (workoutSegments.isNotEmpty && workoutSegments[0].imagePath.isNotEmpty) {
        imagePath = workoutSegments[0].imagePath;
      }
    } else if (isWorkoutSegment) {
      if (currentSegment != null && currentSegment!.imagePath.isNotEmpty) {
        imagePath = currentSegment!.imagePath;
      }
    } else { // 休息片段
      if (nextWorkoutSegment != null && nextWorkoutSegment!.imagePath.isNotEmpty) {
        imagePath = nextWorkoutSegment!.imagePath;
      }
    }

    // 统一标题逻辑
    final String titleText = isBetweenRounds
        ? '轮间休息'
        : (isWorkoutSegment && currentSegment != null
            ? currentSegment!.title
            : '休息时间');

    // 提取 Widgets
    final titleWidget = _buildTitle(context, titleText);
    final nextActionHeaderWidget = _buildNextActionHeader(context);
    final imageWidget = _buildImageWidget(imagePath);
    final descriptionWidget = _buildDescriptionSection(context);
    final infoWidget = _buildInfoCard(context);

    // --- 优化 9: 统一布局结构 ---
    // 大屏：左右布局
    if (isLargeScreen) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧图片
            Expanded(
              flex: 5,
              child: imageWidget,
            ),
            const SizedBox(width: 20),
            // 右侧标题与描述
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  const SizedBox(height: 12),
                  nextActionHeaderWidget,
                  descriptionWidget,
                  infoWidget,
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 小屏/中屏：上下布局
    // --- 优化 10: 简化小屏布局 ---
    // 移除了原版中重复的 "next action" 图片逻辑，
    // 因为 _buildImageWidget(imagePath) 已经处理了所有情况。
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 12),
          nextActionHeaderWidget,
          // 无论什么情况，只要 imagePath 有值就显示
          imageWidget,
          const SizedBox(height: 12),
          descriptionWidget,
          infoWidget,
        ],
      ),
    );
  }
}