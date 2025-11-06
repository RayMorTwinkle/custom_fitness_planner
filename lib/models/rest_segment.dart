// 休息片段数据模型
class RestSegment {
  final String id;
  final int duration; // 时长（秒）
  final String type; // 休息类型：动作间休息、轮间休息等

  RestSegment({
    required this.id,
    required this.duration,
    this.type = '动作间休息',
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
      'duration': duration,
      'type': type,
    };
  }

  // 从Map格式创建对象
  factory RestSegment.fromMap(Map<String, dynamic> map) {
    return RestSegment(
      id: map['id'],
      duration: map['duration'],
      type: map['type'] ?? '动作间休息',
    );
  }

  // 创建副本（用于编辑）
  RestSegment copyWith({
    String? id,
    int? duration,
    String? type,
  }) {
    return RestSegment(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'RestSegment(id: $id, type: $type, duration: $formattedDuration)';
  }
}

// 休息类型枚举
enum RestType {
  betweenExercises('动作间休息'),
  betweenRounds('轮间休息'),
  warmUp('热身休息'),
  coolDown('放松休息');

  final String displayName;
  const RestType(this.displayName);
}