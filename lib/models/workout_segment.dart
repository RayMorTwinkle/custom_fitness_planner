// 训练片段数据模型
class WorkoutSegment {
  final String id;
  final String title;
  final String description;
  final String imagePath; // 动作图片路径
  final int duration; // 时长（秒）
  final String instructions; // 动作说明
  final String difficulty; // 难度级别：初级、中级、高级
  final List<String> targetMuscles; // 目标肌肉群
  final List<String> equipment; // 所需器材

  WorkoutSegment({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.duration,
    this.instructions = '',
    this.difficulty = '中级',
    this.targetMuscles = const [],
    this.equipment = const [],
  });

  // 将时长转换为分钟格式
  String get formattedDuration {
    if (duration < 60) {
      return '$duration秒';
    } else {
      int minutes = duration ~/ 60;
      int seconds = duration % 60;
      if (seconds == 0) {
        return '$minutes分钟';
      } else {
        return '$minutes分$seconds秒';
      }
    }
  }

  // 转换为Map格式（用于存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'duration': duration,
      'instructions': instructions,
      'difficulty': difficulty,
      'targetMuscles': targetMuscles,
      'equipment': equipment,
    };
  }

  // 从Map格式创建对象
  factory WorkoutSegment.fromMap(Map<String, dynamic> map) {
    return WorkoutSegment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      duration: map['duration'],
      instructions: map['instructions'] ?? '',
      difficulty: map['difficulty'] ?? '中级',
      targetMuscles: List<String>.from(map['targetMuscles'] ?? []),
      equipment: List<String>.from(map['equipment'] ?? []),
    );
  }

  // 创建副本（用于编辑）
  WorkoutSegment copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    int? duration,
    String? instructions,
    String? difficulty,
    List<String>? targetMuscles,
    List<String>? equipment,
  }) {
    return WorkoutSegment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      difficulty: difficulty ?? this.difficulty,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      equipment: equipment ?? this.equipment,
    );
  }

  @override
  String toString() {
    return 'WorkoutSegment(id: $id, title: $title, duration: $formattedDuration)';
  }
}

// 难度级别枚举
enum DifficultyLevel {
  beginner('初级'),
  intermediate('中级'),
  advanced('高级');

  final String displayName;
  const DifficultyLevel(this.displayName);
}

// 肌肉群枚举
enum MuscleGroup {
  chest('胸部'),
  back('背部'),
  shoulders('肩部'),
  arms('手臂'),
  legs('腿部'),
  core('核心'),
  glutes('臀部'),
  fullBody('全身');

  final String displayName;
  const MuscleGroup(this.displayName);
}

// 器材枚举
enum Equipment {
  none('无器材'),
  dumbbells('哑铃'),
  barbell('杠铃'),
  kettlebell('壶铃'),
  resistanceBands('弹力带'),
  yogaMat('瑜伽垫'),
  bench('训练凳'),
  pullUpBar('引体向上杆'),
  jumpRope('跳绳');

  final String displayName;
  const Equipment(this.displayName);
}