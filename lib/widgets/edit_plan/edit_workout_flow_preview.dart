/// 文件：edit_workout_flow_preview.dart
/// 类型：可复用组件
/// 描述：训练流程预览组件，支持拖拽重排、删除和复制功能
/// 
/// 主要功能：
/// - 显示训练动作的流程预览
/// - 支持拖拽重排动作顺序
/// - 提供删除和复制拖放区域
/// - 支持动作片段的交互操作
/// 
/// 核心依赖：
/// - models/workout_segment.dart: 训练动作数据模型
/// ↳使用：WorkoutSegment类
/// - flutter/material.dart: Flutter基础UI组件库
/// ↳使用：StatefulWidget、State、DragTarget、Draggable等组件

import 'package:flutter/material.dart';
import '../../models/workout_segment.dart';

/// EditWorkoutFlowPreview
/// 用途：训练流程预览组件，负责显示和编辑训练动作的流程顺序
/// 关联：与EditPlanScreen组件通过回调函数进行数据交互
class EditWorkoutFlowPreview extends StatefulWidget {
   final List<WorkoutSegment> workoutSegments;
   final bool isSmallScreen;
   final void Function(List<WorkoutSegment>)? onWorkoutSegmentsChanged;

   const EditWorkoutFlowPreview({
     super.key,
     required this.workoutSegments,
     required this.isSmallScreen,
     this.onWorkoutSegmentsChanged,
   });

   @override
   State<EditWorkoutFlowPreview> createState() => _EditWorkoutFlowPreviewState();
 }


/// _EditWorkoutFlowPreviewState
/// 用途：EditWorkoutFlowPreview组件的状态管理类，处理拖拽交互和UI状态
/// 关联：管理拖拽状态、悬停状态和动作列表操作
class _EditWorkoutFlowPreviewState extends State<EditWorkoutFlowPreview> {
   final Set<int> _draggingIndices = <int>{}; // 跟踪正在被拖拽的动作方块索引
   bool _isDeleteZoneHovered = false; // 删除区域悬停状态
   bool _isCopyZoneHovered = false; // 复制区域悬停状态

  /// _buildSegmentDecoration
  /// 用途：构建动作方块容器的装饰样式
  /// 参数：isDragging - 是否正在被拖拽
  /// 返回：BoxDecoration - 对应的装饰样式
  BoxDecoration _buildSegmentDecoration(bool isDragging) {
    return BoxDecoration(
      color: isDragging ? Colors.grey[300] : const Color(0xFF2196F3),
      borderRadius: BorderRadius.circular(widget.isSmallScreen ? 8 : 12),
      border: Border.all(
        color: isDragging ? Colors.grey[400]! : const Color(0xFF1976D2),
        width: 1,
      ),
    );
  }

  /// _buildSegmentTextStyle
  /// 用途：构建动作方块文本样式
  /// 参数：isDragging - 是否正在被拖拽
  /// 返回：TextStyle - 对应的文本样式
  TextStyle _buildSegmentTextStyle(bool isDragging) {
    return TextStyle(
      fontSize: widget.isSmallScreen ? 12 : 14,
      color: isDragging ? Colors.grey[600] : Colors.white,
      fontWeight: FontWeight.w500,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workoutSegments.isEmpty) {
      return Container();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(widget.isSmallScreen ? 12.0 : 16.0), // 响应式内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
          children: [
            Row(
              children: [
                Text(
                  '流程预览',
                  style: TextStyle(
                    fontSize: widget.isSmallScreen ? 16.0 : 18.0, // 响应式字体大小
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2196F3), // 主色调
                  ),
                ),
                const SizedBox(width: 8), // 间距
                Text(
                  '(${widget.workoutSegments.length}个动作)', // 显示动作数量
                  style: TextStyle(
                    fontSize: widget.isSmallScreen ? 12.0 : 14.0,
                    color: const Color(0xFF666666), // 次要文字颜色
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // 垂直间距
            _buildDragDropZones(), // 构建拖放区域
            const SizedBox(height: 12), // 垂直间距
            _buildOptimizedFlow(), // 构建流程预览
          ],
        ),
      ),
    );
  }

  /// _buildDragDropZones
  /// 用途：构建拖放区域组件，包含删除和复制功能区域
  /// 返回：Widget - 包含两个拖放区域的Row组件
  Widget _buildDragDropZones() {
    return Row(
      children: [
        Expanded(
          child: DragTarget<WorkoutSegment>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _isDeleteZoneHovered = true;
              });
              return true;
            },
            onLeave: (details) {
              setState(() {
                _isDeleteZoneHovered = false;
              });
            },
            onAcceptWithDetails: (details) async {
              setState(() {
                _isDeleteZoneHovered = false;
              });
              
              // 显示确认对话框，防止误操作
              final bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认删除'),
                    content: Text('确定要删除动作"${details.data.title}"吗？'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('删除'),
                      ),
                    ],
                  );
                },
              );
              
              // 用户确认删除后执行删除操作
              if (confirmDelete == true) {
                setState(() {
                  widget.workoutSegments.remove(details.data); // 从列表中移除该片段
                  widget.onWorkoutSegmentsChanged?.call(List<WorkoutSegment>.from(widget.workoutSegments)); // 通知父组件
                });
              }
            },
            builder: (BuildContext context, List<WorkoutSegment?> candidateData, List<dynamic> rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE57373).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(widget.isSmallScreen ? 8 : 12),
                  color: _isDeleteZoneHovered ? const Color(0xFFFFCDD2).withValues(alpha: 0.3) : Colors.transparent,
                ),
                child: Container(
                  height: widget.isSmallScreen ? 30 : 40,
                  margin: EdgeInsets.all(widget.isSmallScreen ? 8 : 12),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        size: widget.isSmallScreen ? 20 : 24,
                        color: const Color(0xFFE57373).withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '拖拽到此删除',
                        style: TextStyle(
                          fontSize: widget.isSmallScreen ? 12 : 14,
                          color: const Color(0xFFE57373).withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DragTarget<WorkoutSegment>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _isCopyZoneHovered = true;
              });
              return true;
            },
            onLeave: (details) {
              setState(() {
                _isCopyZoneHovered = false;
              });
            },
            onAcceptWithDetails: (details) {
              setState(() {
                _isCopyZoneHovered = false;
                
                // 复制逻辑：找到原始片段位置并创建副本
                final int originalIndex = widget.workoutSegments.indexOf(details.data);
                if (originalIndex != -1) {
                  // 创建副本并生成唯一ID避免冲突
                  final WorkoutSegment newSegment = details.data.copyWith(
                    id: '${details.data.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
                  );
                  
                  // 将副本插入到原始片段的下一个位置
                  final int insertIndex = originalIndex + 1;
                  if (insertIndex <= widget.workoutSegments.length) {
                    widget.workoutSegments.insert(insertIndex, newSegment);
                    widget.onWorkoutSegmentsChanged?.call(List<WorkoutSegment>.from(widget.workoutSegments)); // 通知父组件
                  }
                }
              });
            },
            builder: (BuildContext context, List<WorkoutSegment?> candidateData, List<dynamic> rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF64B5F6).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(widget.isSmallScreen ? 8 : 12),
                  color: _isCopyZoneHovered ? const Color(0xFFE3F2FD) : Colors.transparent,
                ),
                child: Container(
                  height: widget.isSmallScreen ? 30 : 40,
                  margin: EdgeInsets.all(widget.isSmallScreen ? 8 : 12),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.copy,
                        size: widget.isSmallScreen ? 20 : 24,
                        color: const Color(0xFF64B5F6).withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '拖拽到此复制',
                        style: TextStyle(
                          fontSize: widget.isSmallScreen ? 12 : 14,
                          color: const Color(0xFF64B5F6).withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// _buildOptimizedFlow
  /// 用途：构建优化后的流程预览，显示可拖拽的动作方块
  /// 返回：Widget - 包含所有动作方块和箭头指示器的Wrap组件
  Widget _buildOptimizedFlow() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < widget.workoutSegments.length; i++) ...[
          Draggable<WorkoutSegment>(
              data: widget.workoutSegments[i],
              feedback: _buildSegmentContainer(widget.workoutSegments[i].title, false),
              childWhenDragging: _buildSegmentContainer(widget.workoutSegments[i].title, _draggingIndices.contains(i)),
              child: DragTarget<WorkoutSegment>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  setState(() {
                    // 拖拽重排逻辑：获取拖拽物和目标索引
                    final int draggedIndex = widget.workoutSegments.indexOf(details.data);
                    final int targetIndex = i;
                    
                    // 确保不是同一个位置且索引有效
                    if (draggedIndex != targetIndex && draggedIndex != -1) {
                      // 交换两个片段的位置实现重排
                      final WorkoutSegment draggedSegment = widget.workoutSegments[draggedIndex];
                      final WorkoutSegment targetSegment = widget.workoutSegments[targetIndex];
                      
                      widget.workoutSegments[draggedIndex] = targetSegment;
                      widget.workoutSegments[targetIndex] = draggedSegment;
                      
                      widget.onWorkoutSegmentsChanged?.call(List<WorkoutSegment>.from(widget.workoutSegments)); // 通知父组件
                    }
                  });
                },
                onLeave: (details) {
                  // 悬停效果已移除，无需处理
                },
                builder: (BuildContext context, List<WorkoutSegment?> candidateData, List<dynamic> rejectedData) {
                  return _buildSegmentContainer(widget.workoutSegments[i].title, false);
                },
              ),
            onDragStarted: () => setState(() => _draggingIndices.add(i)),
            onDragEnd: (details) => setState(() => _draggingIndices.remove(i)),
            onDraggableCanceled: (velocity, offset) => setState(() => _draggingIndices.remove(i)),
          ),
          if (i < widget.workoutSegments.length - 1)
            Icon(
              Icons.arrow_forward,
              size: widget.isSmallScreen ? 16 : 20,
              color: const Color(0xFF757575),
            ),
        ],
      ],
    );
  }

  /// _buildSegmentContainer
  /// 用途：构建动作方块容器，包含动作标题和样式
  /// 参数：title - 动作标题，isDragging - 是否正在被拖拽
  /// 返回：Widget - 包含动作标题的容器组件
  Widget _buildSegmentContainer(String title, bool isDragging) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmallScreen ? 12 : 16,
        vertical: widget.isSmallScreen ? 8 : 12,
      ),
      decoration: _buildSegmentDecoration(isDragging),
      child: Text(
        title,
        style: _buildSegmentTextStyle(isDragging),
      ),
    );
  }
}