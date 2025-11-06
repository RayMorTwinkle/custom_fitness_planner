// 示例数据
import 'fitness_plan.dart';
import 'workout_segment.dart';
import 'rest_segment.dart';

class SampleData {
  // 示例训练片段
  static final List<WorkoutSegment> sampleWorkoutSegments = [
    WorkoutSegment(
      id: '1',
      title: '深蹲',
      description: '基础下肢训练动作',
      imagePath: 'assets/images/squat.jpg',
      duration: 60,
      instructions: '双脚与肩同宽，膝盖不要超过脚尖，保持背部挺直',
      difficulty: '初级',
      targetMuscles: ['腿部', '臀部'],
      equipment: ['无器材'],
    ),
    WorkoutSegment(
      id: '2',
      title: '俯卧撑',
      description: '经典上肢力量训练',
      imagePath: 'assets/images/pushup.jpg',
      duration: 45,
      instructions: '双手与肩同宽，身体保持直线，胸部贴近地面',
      difficulty: '中级',
      targetMuscles: ['胸部', '肩部', '手臂'],
      equipment: ['无器材'],
    ),
    WorkoutSegment(
      id: '3',
      title: '平板支撑',
      description: '核心稳定性训练',
      imagePath: 'assets/images/plank.jpg',
      duration: 90,
      instructions: '手肘支撑，身体保持直线，收紧核心',
      difficulty: '初级',
      targetMuscles: ['核心'],
      equipment: ['瑜伽垫'],
    ),
    WorkoutSegment(
      id: '4',
      title: '弓步蹲',
      description: '单侧下肢训练',
      imagePath: 'assets/images/lunge.jpg',
      duration: 60,
      instructions: '向前迈步，膝盖弯曲90度，保持身体平衡',
      difficulty: '中级',
      targetMuscles: ['腿部', '臀部'],
      equipment: ['无器材'],
    ),
    WorkoutSegment(
      id: '5',
      title: '仰卧起坐',
      description: '腹部核心训练',
      imagePath: 'assets/images/situp.jpg',
      duration: 45,
      instructions: '膝盖弯曲，双手交叉胸前，缓慢起身',
      difficulty: '初级',
      targetMuscles: ['腹部'],
      equipment: ['瑜伽垫'],
    ),
  ];

  // 示例休息片段
  static final List<RestSegment> sampleRestSegments = [
    RestSegment(
      id: 'r1',
      duration: 30,
      type: '动作间休息',
    ),
    RestSegment(
      id: 'r2',
      duration: 60,
      type: '轮间休息',
    ),
  ];

  // 示例健身计划
  static final List<FitnessPlan> sampleFitnessPlans = [
    FitnessPlan(
      id: 'p1',
      title: '全身训练计划',
      description: '45分钟全身综合训练，适合初学者',
      type: '全身训练',
      imagePath: 'assets/images/full_body.jpg',
      workoutSegments: [sampleWorkoutSegments[0], sampleWorkoutSegments[1], sampleWorkoutSegments[2]],
      restSegments: [sampleRestSegments[0]],
      totalRounds: 3,
      restBetweenRounds: 60,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    FitnessPlan(
      id: 'p2',
      title: '上肢力量训练',
      description: '30分钟上肢专项训练，提升力量',
      type: '上肢训练',
      imagePath: 'assets/images/upper_body.jpg',
      workoutSegments: [sampleWorkoutSegments[1]],
      restSegments: [sampleRestSegments[0]],
      totalRounds: 4,
      restBetweenRounds: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FitnessPlan(
      id: 'p3',
      title: '下肢训练',
      description: '35分钟下肢强化训练',
      type: '下肢训练',
      imagePath: 'assets/images/lower_body.jpg',
      workoutSegments: [sampleWorkoutSegments[0], sampleWorkoutSegments[3]],
      restSegments: [sampleRestSegments[0]],
      totalRounds: 3,
      restBetweenRounds: 60,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FitnessPlan(
      id: 'p4',
      title: '核心训练',
      description: '25分钟核心稳定性训练',
      type: '核心训练',
      imagePath: 'assets/images/core.jpg',
      workoutSegments: [sampleWorkoutSegments[2], sampleWorkoutSegments[4]],
      restSegments: [sampleRestSegments[0]],
      totalRounds: 3,
      restBetweenRounds: 30,
      createdAt: DateTime.now(),
    ),
  ];

  // 获取默认健身计划（用于主页显示）
  static FitnessPlan get defaultFitnessPlan => sampleFitnessPlans[0];

  // 根据类型获取计划
  static List<FitnessPlan> getPlansByType(String type) {
    return sampleFitnessPlans.where((plan) => plan.type == type).toList();
  }

  // 获取所有计划类型
  static List<String> get allPlanTypes {
    return sampleFitnessPlans.map((plan) => plan.type).toSet().toList();
  }
}