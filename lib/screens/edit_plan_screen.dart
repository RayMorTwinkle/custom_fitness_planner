import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_plan_provider.dart';
import '../models/fitness_plan.dart';
import '../models/workout_segment.dart';
import '../models/rest_segment.dart';
import '../utils/settings_manager.dart';
import '../widgets/edit_plan/edit_plan_info_card.dart';
import '../widgets/edit_plan/edit_workout_segment_card.dart';
import '../widgets/edit_plan/edit_rest_segment_card.dart';
import '../widgets/edit_plan/edit_workout_flow_builder.dart';
import '../widgets/edit_plan/edit_workout_flow_preview.dart';

class EditPlanScreen extends StatefulWidget {
  final FitnessPlan? plan;
  final bool isCreateMode;
  
  const EditPlanScreen({super.key, required this.plan}) : isCreateMode = plan == null;

  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _totalRoundsController;
  late final TextEditingController _restBetweenRoundsController;
  
  // 默认时长值
  int _defaultWorkoutDuration = 30;
  int _defaultRestDuration = 20;

  @override
  void initState() {
    super.initState();
    
    if (widget.isCreateMode) {
      // 创建模式：使用默认数据初始化
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _totalRoundsController = TextEditingController(text: '3');
      _restBetweenRoundsController = TextEditingController(text: '60');
      
      // 初始化默认训练片段
      _workoutSegments = [];
      
      // 加载默认设置并初始化数据
      _loadDefaultSettings().then((_) {
        // 在默认设置加载完成后初始化训练片段
        setState(() {
          _workoutSegments = [
            WorkoutSegment(
              id: '1',
              title: '深蹲',
              description: '腿部力量训练',
              imagePath: '',
              duration: _defaultWorkoutDuration,
            ),
            WorkoutSegment(
              id: '2',
              title: '俯卧撑',
              description: '胸部力量训练',
              imagePath: '',
              duration: _defaultWorkoutDuration,
            ),
          ];
          
          // 初始化控制器列表
          _workoutTitleControllers = [
            TextEditingController(text: '深蹲'),
            TextEditingController(text: '俯卧撑')
          ];
          _workoutDescriptionControllers = [
            TextEditingController(text: '腿部力量训练'),
            TextEditingController(text: '胸部力量训练')
          ];
          _workoutDurationControllers = [
            TextEditingController(text: _defaultWorkoutDuration.toString()),
            TextEditingController(text: _defaultWorkoutDuration.toString())
          ];
          
          // 初始化休息片段
          _restDurations = [_defaultRestDuration];
          _restDurationControllers = [TextEditingController(text: _defaultRestDuration.toString())];
        });
      });
    } else {
      // 编辑模式：预填充已有计划数据
      if (widget.plan != null) {
        _titleController = TextEditingController(text: widget.plan!.title);
        _descriptionController = TextEditingController(text: widget.plan!.description);
        _totalRoundsController = TextEditingController(text: widget.plan!.totalRounds.toString());
        _restBetweenRoundsController = TextEditingController(text: widget.plan!.restBetweenRounds.toString());
        
        // 复制训练片段列表（避免直接修改原对象）
        _workoutSegments = List<WorkoutSegment>.from(widget.plan!.workoutSegments);
        
        // 初始化训练片段控制器列表
        for (final segment in _workoutSegments) {
          _workoutTitleControllers.add(TextEditingController(text: segment.title));
          _workoutDescriptionControllers.add(TextEditingController(text: segment.description));
          _workoutDurationControllers.add(TextEditingController(text: segment.duration.toString()));
        }
        
        // 初始化休息片段数据
        for (final segment in widget.plan!.restSegments) {
          _restDurations.add(segment.duration);
          _restDurationControllers.add(TextEditingController(text: segment.duration.toString()));
        }
      }
      
      // 加载默认设置
      _loadDefaultSettings();
    }
  }
  
  // 加载默认设置
  Future<void> _loadDefaultSettings() async {
    final workoutDuration = await SettingsManager.getSegmentDuration();
    final restDuration = await SettingsManager.getRestDuration();
    
    setState(() {
      _defaultWorkoutDuration = workoutDuration.toInt();
      _defaultRestDuration = restDuration.toInt();
    });
  }

  // 训练片段列表
  List<WorkoutSegment> _workoutSegments = [];

  // 休息片段时长列表（每个休息片段的时长）
  List<int> _restDurations = [];
  
  // 用于存储训练片段输入框的控制器
  List<TextEditingController> _workoutTitleControllers = [];
  List<TextEditingController> _workoutDescriptionControllers = [];
  List<TextEditingController> _workoutDurationControllers = [];
  
  // 用于存储休息片段输入框的控制器
  List<TextEditingController> _restDurationControllers = [];

  // 休息片段列表（根据训练片段数量自动生成）
  List<RestSegment> get _restSegments {
    if (_workoutSegments.length <= 1) {
      return [];
    }
    
    // 确保休息片段数量与训练片段数量匹配
    final restCount = _workoutSegments.length - 1;
    if (_restDurations.length < restCount) {
      // 如果休息片段数量不足，添加默认值
      for (int i = _restDurations.length; i < restCount; i++) {
        _restDurations.add(_defaultRestDuration);
        _restDurationControllers.add(TextEditingController(text: _defaultRestDuration.toString()));
      }
    } else if (_restDurations.length > restCount) {
      // 如果休息片段数量过多，截断
      _restDurations = _restDurations.sublist(0, restCount);
      _restDurationControllers = _restDurationControllers.sublist(0, restCount);
    }
    
    return List.generate(restCount, (index) {
      return RestSegment(id: 'r${index + 1}', duration: _restDurations[index]);
    });
  }

  void _updateWorkoutSegment(int index, WorkoutSegment updatedSegment) {
    setState(() {
      _workoutSegments[index] = updatedSegment;
    });
  }

  // 增加训练片段
  void _addWorkoutSegment() {
    // 限制训练片段数量最多为20个
    if (_workoutSegments.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('训练片段数量已达到上限（20个）'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      final newId = (_workoutSegments.length + 1).toString();
      _workoutSegments.add(WorkoutSegment(
        id: newId,
        title: '新动作',
        description: '动作描述',
        imagePath: '',
        duration: _defaultWorkoutDuration,
      ));
      
      // 添加对应的控制器
      _workoutTitleControllers.add(TextEditingController(text: '新动作'));
      _workoutDescriptionControllers.add(TextEditingController(text: '动作描述'));
      _workoutDurationControllers.add(TextEditingController(text: _defaultWorkoutDuration.toString()));
    });
  }

  // 删除训练片段
  void _deleteWorkoutSegment(int index) {
    setState(() {
      _workoutSegments.removeAt(index);
      
      // 删除对应的控制器
      _workoutTitleControllers.removeAt(index);
      _workoutDescriptionControllers.removeAt(index);
      _workoutDurationControllers.removeAt(index);
      
      // 重新生成所有训练片段的ID，确保连续
      for (int i = 0; i < _workoutSegments.length; i++) {
        _workoutSegments[i] = _workoutSegments[i].copyWith(id: (i + 1).toString());
      }
    });
  }

  // 更新控制器列表以匹配训练片段列表
  void _updateControllersForSegments() {
    // 确保控制器数量与训练片段数量匹配
    while (_workoutTitleControllers.length > _workoutSegments.length) {
      _workoutTitleControllers.removeLast().dispose();
      _workoutDescriptionControllers.removeLast().dispose();
      _workoutDurationControllers.removeLast().dispose();
    }
    
    while (_workoutTitleControllers.length < _workoutSegments.length) {
      final index = _workoutTitleControllers.length;
      _workoutTitleControllers.add(TextEditingController(text: _workoutSegments[index].title));
      _workoutDescriptionControllers.add(TextEditingController(text: _workoutSegments[index].description));
      _workoutDurationControllers.add(TextEditingController(text: _workoutSegments[index].duration.toString()));
    }
    
    // 更新现有控制器的值
    for (int i = 0; i < _workoutSegments.length; i++) {
      if (_workoutTitleControllers[i].text != _workoutSegments[i].title) {
        _workoutTitleControllers[i].text = _workoutSegments[i].title;
      }
      if (_workoutDescriptionControllers[i].text != _workoutSegments[i].description) {
        _workoutDescriptionControllers[i].text = _workoutSegments[i].description;
      }
      if (_workoutDurationControllers[i].text != _workoutSegments[i].duration.toString()) {
        _workoutDurationControllers[i].text = _workoutSegments[i].duration.toString();
      }
    }
  }

  // 从相册选择图片
  Future<void> _pickImageFromGallery(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        // 检查文件是否存在且可读
        final file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _workoutSegments[index] = _workoutSegments[index].copyWith(imagePath: image.path);
          });
        } else {
          // 如果文件不存在，尝试使用其他方式获取路径
          setState(() {
            _workoutSegments[index] = _workoutSegments[index].copyWith(imagePath: image.path);
          });
        }
      }
    } catch (e) {
      print('图片选择错误: $e');
      // 可以在这里添加错误提示
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _workoutSegments[index] = _workoutSegments[index].copyWith(imagePath: '');
    });
  }

  // 获取所有输入框的值并更新片段
  void _updateAllSegmentsFromInputs() {
    // 更新训练片段数据
    for (int i = 0; i < _workoutSegments.length; i++) {
      final title = _workoutTitleControllers[i].text.trim();
      final description = _workoutDescriptionControllers[i].text.trim();
      final durationText = _workoutDurationControllers[i].text.trim();
      final duration = int.tryParse(durationText) ?? 30;
      
      _workoutSegments[i] = _workoutSegments[i].copyWith(
        title: title.isNotEmpty ? title : '新动作',
        description: description.isNotEmpty ? description : '动作描述',
        duration: duration > 0 ? duration : 30,
      );
    }
    
    // 更新休息片段数据
    for (int i = 0; i < _restSegments.length; i++) {
      final durationText = _restDurationControllers[i].text.trim();
      final duration = int.tryParse(durationText) ?? 20;
      
      if (duration > 0) {
        _restDurations[i] = duration;
      }
    }
  }

  // 显示删除确认对话框
  void _showDeleteConfirmation(BuildContext context) {
    if (widget.plan == null) return; // 创建模式下不显示删除确认
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除计划"${widget.plan!.title}"吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                _deletePlan(context); // 执行删除
              },
              child: const Text(
                '删除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // 删除计划
  void _deletePlan(BuildContext context) {
    if (widget.plan == null) return; // 创建模式下不执行删除
    
    final fitnessPlanProvider = Provider.of<FitnessPlanProvider>(context, listen: false);
    fitnessPlanProvider.deletePlan(widget.plan!.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('计划"${widget.plan!.title}"已删除')),
    );
    
    Navigator.of(context).pop(); // 返回上一页
  }

  void _savePlan(BuildContext context) {
    // 在保存前获取所有输入框的值
    _updateAllSegmentsFromInputs();
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入计划标题')),
      );
      return;
    }

    // 检查训练片段时长是否为空
    for (int i = 0; i < _workoutSegments.length; i++) {
      if (_workoutSegments[i].duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请为训练片段 ${i + 1} 设置时长')),
        );
        return;
      }
    }

    // 检查休息片段时长是否为空
    for (int i = 0; i < _restSegments.length; i++) {
      if (_restSegments[i].duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请为休息片段 ${i + 1} 设置时长')),
        );
        return;
      }
    }

    final totalRounds = int.tryParse(_totalRoundsController.text) ?? 3;
    final restBetweenRounds = int.tryParse(_restBetweenRoundsController.text) ?? 60;

    final fitnessPlanProvider = Provider.of<FitnessPlanProvider>(context, listen: false);

    if (widget.isCreateMode) {
      // 创建模式：添加新计划
      final newPlan = FitnessPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 生成新ID
        title: _titleController.text,
        description: _descriptionController.text.isEmpty 
            ? '自定义训练计划' 
            : _descriptionController.text,
        type: 'custom', // 默认类型
        imagePath: '', // 空图片路径
        workoutSegments: _workoutSegments,
        restSegments: _restSegments,
        totalRounds: totalRounds,
        restBetweenRounds: restBetweenRounds,
        createdAt: DateTime.now(), // 当前时间
      );

      fitnessPlanProvider.addPlan(newPlan);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('计划创建成功')),
      );
    } else {
      // 编辑模式：更新现有计划
      if (widget.plan != null) {
        final updatedPlan = FitnessPlan(
          id: widget.plan!.id, // 保持原ID
          title: _titleController.text,
          description: _descriptionController.text.isEmpty 
              ? '自定义训练计划' 
              : _descriptionController.text,
          type: widget.plan!.type, // 保持原类型
          imagePath: widget.plan!.imagePath, // 保持原图片路径
          workoutSegments: _workoutSegments,
          restSegments: _restSegments,
          totalRounds: totalRounds,
          restBetweenRounds: restBetweenRounds,
          createdAt: widget.plan!.createdAt, // 保持原创建时间
        );

        fitnessPlanProvider.updatePlan(widget.plan!.id, updatedPlan);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('计划更新成功')),
        );
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreateMode ? '创建新计划' : '编辑计划'),
        actions: [
          if (!widget.isCreateMode) IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete),
            tooltip: '删除计划',
            color: Colors.red,
          ),
          IconButton(
            onPressed: () => _savePlan(context),
            icon: const Icon(Icons.save),
            tooltip: '保存计划',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          
          // 响应式断点
          final bool isSmallScreen = screenWidth < 600;
          final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
          
          // 响应式尺寸计算
          final double paddingValue = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;
          final double spacingValue = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;
          final double largeSpacingValue = isSmallScreen ? 20.0 : isMediumScreen ? 24.0 : 32.0;
          
          // 响应式字体大小
          final double titleFontSize = isSmallScreen ? 18.0 : isMediumScreen ? 20.0 : 22.0;
          final double subtitleFontSize = isSmallScreen ? 14.0 : isMediumScreen ? 16.0 : 18.0;
          final double bodyFontSize = isSmallScreen ? 12.0 : isMediumScreen ? 14.0 : 16.0;
          
          return Padding(
            padding: EdgeInsets.all(paddingValue),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 计划基本信息 - 使用新组件
                  EditPlanInfoCard(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    totalRoundsController: _totalRoundsController,
                    restBetweenRoundsController: _restBetweenRoundsController,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: largeSpacingValue),

                  // 流程预览区域
                  EditWorkoutFlowPreview(
                    workoutSegments: _workoutSegments,
                    isSmallScreen: isSmallScreen,
                    onWorkoutSegmentsChanged: (updatedSegments) {
                      setState(() {
                        _workoutSegments = updatedSegments;
                        // 更新对应的控制器列表
                        _updateControllersForSegments();
                      });
                    },
                  ),

                  SizedBox(height: largeSpacingValue),

                  // 训练和休息片段交替显示 - 使用新组件
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(paddingValue * 1.25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 在小屏幕上改为垂直布局
                          isSmallScreen
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '训练流程',
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                    SizedBox(height: spacingValue / 2),
                                    Text(
                                      '(${_workoutSegments.length}个训练 + ${_restSegments.length}个休息)',
                                      style: TextStyle(
                                        fontSize: bodyFontSize,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Text(
                                      '训练流程',
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                    SizedBox(width: spacingValue),
                                    Text(
                                      '(${_workoutSegments.length}个训练 + ${_restSegments.length}个休息)',
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: spacingValue),
                          // 交替显示训练片段和休息片段 - 使用新组件
                          EditWorkoutFlowBuilder(
                            workoutSegments: _workoutSegments,
                            restSegments: _restSegments,
                            onBuildWorkoutSegment: (index, segment) => EditWorkoutSegmentCard(
                              segment: segment,
                              index: index,
                              titleController: _workoutTitleControllers[index],
                              descriptionController: _workoutDescriptionControllers[index],
                              durationController: _workoutDurationControllers[index],
                              onPickImage: _pickImageFromGallery,
                              onRemoveImage: _removeImage,
                              onDelete: _deleteWorkoutSegment,
                              canDelete: _workoutSegments.length > 1,
                              onUpdate: _updateWorkoutSegment,
                              isSmallScreen: isSmallScreen,
                            ),
                            onBuildRestSegment: (index, segment) => EditRestSegmentCard(
                              segment: segment,
                              index: index,
                              durationController: _restDurationControllers[index],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: largeSpacingValue * 2),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final bool isSmallScreen = screenWidth < 600;
          
          // 响应式浮动按钮大小
          final double fabSize = isSmallScreen ? 48.0 : 56.0;
          final double fabSpacing = isSmallScreen ? 8.0 : 12.0;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: _addWorkoutSegment,
                icon: Icon(Icons.add, size: fabSize * 0.6),
                label: Text(
                  '增加训练片段',
                  style: TextStyle(fontSize: isSmallScreen ? 12.0 : 14.0),
                ),
                heroTag: 'add_workout',
              ),
              SizedBox(height: fabSpacing),
              FloatingActionButton.extended(
                onPressed: () => _savePlan(context),
                icon: Icon(Icons.save, size: fabSize * 0.6),
                label: Text(
                  '保存计划',
                  style: TextStyle(fontSize: isSmallScreen ? 12.0 : 14.0),
                ),
                heroTag: 'save_plan',
              ),
            ],
          );
        },
      ),
    );
  }



  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalRoundsController.dispose();
    _restBetweenRoundsController.dispose();
    
    // 释放训练片段控制器
    for (final controller in _workoutTitleControllers) {
      controller.dispose();
    }
    for (final controller in _workoutDescriptionControllers) {
      controller.dispose();
    }
    for (final controller in _workoutDurationControllers) {
      controller.dispose();
    }
    
    // 释放休息片段控制器
    for (final controller in _restDurationControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}