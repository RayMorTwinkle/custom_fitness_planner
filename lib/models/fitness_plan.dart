// 健身计划数据模型
import 'workout_segment.dart';
import 'rest_segment.dart';

class FitnessPlan {
  final String id;
  final String title;
  final String description;
  final String type; // 计划类型：全身、上肢、下肢、核心等
  final String imagePath; // 计划封面图片路径
  final List<WorkoutSegment> workoutSegments; // 训练片段列表
  final List<RestSegment> restSegments; // 休息片段列表
  final int totalRounds; // 总轮数
  final int restBetweenRounds; // 轮间休息时长（秒）
  final DateTime createdAt;
  final DateTime? updatedAt;

  FitnessPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.imagePath,
    required this.workoutSegments,
    required this.restSegments,
    required this.totalRounds,
    required this.restBetweenRounds,
    required this.createdAt,
    this.updatedAt,
  });

  // 计算总训练时长（秒）
  int get totalWorkoutDuration {
    int workoutDuration = workoutSegments.fold(0, (sum, segment) => sum + segment.duration);
    int restDuration = restSegments.fold(0, (sum, segment) => sum + segment.duration);
    int roundDuration = workoutDuration + restDuration;
    int totalDuration = roundDuration * totalRounds;
    
    // 添加轮间休息时间（最后一轮后没有休息）
    if (totalRounds > 1) {
      totalDuration += restBetweenRounds * (totalRounds - 1);
    }
    
    return totalDuration;
  }

  // 将总时长转换为分钟格式
  String get formattedDuration {
    int totalMinutes = totalWorkoutDuration ~/ 60;
    int remainingSeconds = totalWorkoutDuration % 60;
    
    if (remainingSeconds == 0) {
      return '$totalMinutes分钟';
    } else {
      return '$totalMinutes分$remainingSeconds秒';
    }
  }

  // 转换为Map格式（用于存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'imagePath': imagePath,
      'workoutSegments': workoutSegments.map((segment) => segment.toMap()).toList(),
      'restSegments': restSegments.map((segment) => segment.toMap()).toList(),
      'totalRounds': totalRounds,
      'restBetweenRounds': restBetweenRounds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // 从Map格式创建对象
  factory FitnessPlan.fromMap(Map<String, dynamic> map) {
    return FitnessPlan(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      imagePath: map['imagePath'],
      workoutSegments: List<WorkoutSegment>.from(
        map['workoutSegments'].map((segmentMap) => WorkoutSegment.fromMap(segmentMap))
      ),
      restSegments: List<RestSegment>.from(
        map['restSegments'].map((segmentMap) => RestSegment.fromMap(segmentMap))
      ),
      totalRounds: map['totalRounds'],
      restBetweenRounds: map['restBetweenRounds'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) : null,
    );
  }

  // 创建副本（用于编辑）
  FitnessPlan copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? imagePath,
    List<WorkoutSegment>? workoutSegments,
    List<RestSegment>? restSegments,
    int? totalRounds,
    int? restBetweenRounds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FitnessPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      workoutSegments: workoutSegments ?? this.workoutSegments,
      restSegments: restSegments ?? this.restSegments,
      totalRounds: totalRounds ?? this.totalRounds,
      restBetweenRounds: restBetweenRounds ?? this.restBetweenRounds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FitnessPlan(id: $id, title: $title, type: $type, rounds: $totalRounds, duration: $formattedDuration)';
  }
}

// 计划类型枚举
enum PlanType {
  fullBody('全身训练'),
  upperBody('上肢训练'),
  lowerBody('下肢训练'),
  core('核心训练'),
  cardio('有氧训练'),
  flexibility('柔韧性训练');

  final String displayName;
  const PlanType(this.displayName);
}