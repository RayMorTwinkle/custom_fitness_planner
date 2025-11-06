import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fitness_plan.dart';
import '../models/sample_data.dart';

class FitnessPlanProvider with ChangeNotifier {
  static const String _plansKey = 'fitness_plans';
  static const String _selectedPlanKey = 'selected_plan';
  // 健身计划列表
  List<FitnessPlan> _fitnessPlans = [];
  
  // 当前选择的默认计划
  FitnessPlan? _selectedPlan;
  
  // 构造函数 - 初始化数据
  FitnessPlanProvider() {
    _loadPlans();
  }
  
  // 获取健身计划列表
  List<FitnessPlan> get fitnessPlans => List.unmodifiable(_fitnessPlans);
  
  // 获取当前选择的计划
  FitnessPlan? get selectedPlan => _selectedPlan;
  
  // 获取默认计划（如果没有选择，则返回第一个计划）
  FitnessPlan get defaultPlan => _selectedPlan ?? _fitnessPlans.first;
  
  // 检查计划是否为默认计划
  bool isDefaultPlan(FitnessPlan plan) {
    return _selectedPlan?.id == plan.id;
  }
  
  // 切换默认计划
  void toggleDefaultPlan(FitnessPlan plan) {
    if (isDefaultPlan(plan)) {
      // 如果已经是默认计划，则取消默认
      _selectedPlan = null;
    } else {
      // 设置为默认计划
      _selectedPlan = plan;
    }
    notifyListeners();
    _savePlans();
  }
  
  // 加载计划数据（优先从本地存储加载）
  Future<void> _loadPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getString(_plansKey);
      final selectedPlanId = prefs.getString(_selectedPlanKey);
      
      if (plansJson != null && plansJson.isNotEmpty) {
        // 从本地存储加载计划
        final List<dynamic> plansList = List<dynamic>.from(json.decode(plansJson));
        _fitnessPlans = plansList.map((planMap) => FitnessPlan.fromMap(planMap)).toList();
        
        // 设置选中的计划
        if (selectedPlanId != null && _fitnessPlans.isNotEmpty) {
          _selectedPlan = _fitnessPlans.firstWhere(
            (plan) => plan.id == selectedPlanId,
            orElse: () => _fitnessPlans.first,
          );
        } else if (_fitnessPlans.isNotEmpty) {
          _selectedPlan = _fitnessPlans.first;
        }
      } else {
        // 如果没有本地数据，加载示例数据
        _loadSampleData();
      }
      
      notifyListeners();
    } catch (e) {
      // 如果加载失败，使用示例数据
      print('加载计划数据失败: $e');
      _loadSampleData();
    }
  }
  
  // 保存计划数据到本地存储
  Future<void> _savePlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = json.encode(_fitnessPlans.map((plan) => plan.toMap()).toList());
      await prefs.setString(_plansKey, plansJson);
      
      // 保存选中的计划ID
      if (_selectedPlan != null) {
        await prefs.setString(_selectedPlanKey, _selectedPlan!.id);
      } else {
        await prefs.remove(_selectedPlanKey);
      }
    } catch (e) {
      print('保存计划数据失败: $e');
    }
  }
  
  // 加载示例数据
  void _loadSampleData() {
    _fitnessPlans = SampleData.sampleFitnessPlans;
    _selectedPlan = _fitnessPlans.isNotEmpty ? _fitnessPlans.first : null;
    notifyListeners();
  }
  
  // 设置当前选择的计划
  void selectPlan(FitnessPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
    _savePlans();
  }
  
  // 根据ID选择计划
  void selectPlanById(String planId) {
    final plan = _fitnessPlans.firstWhere(
      (plan) => plan.id == planId,
      orElse: () => _fitnessPlans.first,
    );
    selectPlan(plan);
  }
  
  // 添加新的健身计划
  void addPlan(FitnessPlan plan) {
    _fitnessPlans.add(plan);
    notifyListeners();
    _savePlans();
  }
  
  // 更新现有的健身计划
  void updatePlan(String planId, FitnessPlan updatedPlan) {
    final index = _fitnessPlans.indexWhere((plan) => plan.id == planId);
    if (index != -1) {
      _fitnessPlans[index] = updatedPlan;
      
      // 如果更新的是当前选择的计划，也更新选择
      if (_selectedPlan?.id == planId) {
        _selectedPlan = updatedPlan;
      }
      
      notifyListeners();
      _savePlans();
    }
  }
  
  // 删除健身计划
  void deletePlan(String planId) {
    _fitnessPlans.removeWhere((plan) => plan.id == planId);
    
    // 如果删除的是当前选择的计划，重置选择
    if (_selectedPlan?.id == planId) {
      _selectedPlan = _fitnessPlans.isNotEmpty ? _fitnessPlans.first : null;
    }
    
    notifyListeners();
    _savePlans();
  }
  
  // 根据类型筛选计划
  List<FitnessPlan> getPlansByType(String type) {
    return _fitnessPlans.where((plan) => plan.type == type).toList();
  }
  
  // 获取所有计划类型
  List<String> get allPlanTypes {
    return _fitnessPlans.map((plan) => plan.type).toSet().toList();
  }
  
  // 搜索计划
  List<FitnessPlan> searchPlans(String query) {
    if (query.isEmpty) return _fitnessPlans;
    
    return _fitnessPlans.where((plan) {
      return plan.title.toLowerCase().contains(query.toLowerCase()) ||
             plan.description.toLowerCase().contains(query.toLowerCase()) ||
             plan.type.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  
  // 获取计划数量统计
  Map<String, int> get planStatistics {
    final Map<String, int> stats = {};
    
    for (final plan in _fitnessPlans) {
      stats[plan.type] = (stats[plan.type] ?? 0) + 1;
    }
    
    return stats;
  }
  
  // 获取总训练时长统计
  int get totalTrainingDuration {
    return _fitnessPlans.fold(0, (sum, plan) => sum + plan.totalWorkoutDuration);
  }
  
  // 格式化总训练时长
  String get formattedTotalTrainingDuration {
    final totalSeconds = totalTrainingDuration;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    } else {
      return '$minutes分钟';
    }
  }
  
  // 检查计划是否存在
  bool planExists(String planId) {
    return _fitnessPlans.any((plan) => plan.id == planId);
  }
  
  // 获取下一个计划的ID（用于创建新计划）
  String getNextPlanId() {
    if (_fitnessPlans.isEmpty) return 'p1';
    
    final lastId = _fitnessPlans.last.id;
    final number = int.tryParse(lastId.substring(1)) ?? 0;
    return 'p${number + 1}';
  }
  
  // 重置为示例数据
  void resetToSampleData() {
    _loadSampleData();
  }
}