import 'package:flutter/material.dart';
import 'package:flowfit/models/workout_segment.dart';
import 'package:flowfit/models/rest_segment.dart';

class EditWorkoutFlowBuilder extends StatelessWidget {
  final List<WorkoutSegment> workoutSegments;
  final List<RestSegment> restSegments;
  final Widget Function(int, WorkoutSegment) onBuildWorkoutSegment;
  final Widget Function(int, RestSegment) onBuildRestSegment;

  const EditWorkoutFlowBuilder({
    super.key,
    required this.workoutSegments,
    required this.restSegments,
    required this.onBuildWorkoutSegment,
    required this.onBuildRestSegment,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> flowWidgets = [];
    
    for (int i = 0; i < workoutSegments.length; i++) {
      // 添加训练片段
      flowWidgets.add(onBuildWorkoutSegment(i, workoutSegments[i]));
      
      // 如果不是最后一个训练片段，添加休息片段
      if (i < restSegments.length) {
        flowWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '休息 ${i + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
        flowWidgets.add(onBuildRestSegment(i, restSegments[i]));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: flowWidgets,
    );
  }
}