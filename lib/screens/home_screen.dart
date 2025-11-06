import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_plan_provider.dart';
import '../models/fitness_plan.dart';
import 'workout_execution_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startWorkout(BuildContext context, FitnessPlan defaultPlan) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => WorkoutExecutionScreen(plan: defaultPlan)),
     );
   }

  @override
  Widget build(BuildContext context) {
    final fitnessPlanProvider = Provider.of<FitnessPlanProvider>(context);
    final fitnessPlans = fitnessPlanProvider.fitnessPlans;
    
    // 获取屏幕尺寸信息
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // 定义断点
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
    
    // 响应式字体大小
    final titleFontSize = isSmallScreen ? 24.0 : isMediumScreen ? 28.0 : 32.0;
    final subtitleFontSize = isSmallScreen ? 16.0 : isMediumScreen ? 18.0 : 20.0;
    final bodyFontSize = isSmallScreen ? 14.0 : isMediumScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : isMediumScreen ? 14.0 : 16.0;
    
    // 响应式间距
    final smallSpacing = screenHeight * 0.01;
    final mediumSpacing = screenHeight * 0.02;
    final largeSpacing = screenHeight * 0.03;
    
    // 响应式图标大小
    final iconSize = isSmallScreen ? 60.0 : isMediumScreen ? 80.0 : 100.0;
    final iconInnerSize = isSmallScreen ? 30.0 : isMediumScreen ? 40.0 : 50.0;
    
    // 响应式按钮高度
    final buttonHeight = isSmallScreen ? 50.0 : isMediumScreen ? 55.0 : 60.0;
    
    // 响应式内边距
    final paddingValue = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;
    final cardPadding = isSmallScreen ? 16.0 : isMediumScreen ? 20.0 : 24.0;
    
    // 检查是否有可用的计划
    if (fitnessPlans.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('主页'),
        ),
        body: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: iconSize,
                color: Colors.grey[400],
              ),
              SizedBox(height: mediumSpacing),
              Text(
                '暂无健身计划',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: smallSpacing),
              Text(
                '请先创建您的第一个健身计划',
                style: TextStyle(
                  fontSize: bodyFontSize,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: largeSpacing),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/plans');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '创建计划',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final defaultPlan = fitnessPlanProvider.defaultPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 标题区域
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: titleFontSize,
                      color: const Color(0xFF4CAF50),
                    ),
                    SizedBox(width: smallSpacing),
                    Text(
                      '您的训练',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: mediumSpacing),
                
                // 计划预览区域
                SizedBox(
                  width: double.infinity,
                  height: constraints.maxHeight * 0.7, // 使用相对高度而非Expanded
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              size: iconInnerSize,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          SizedBox(height: mediumSpacing),
                          Text(
                            defaultPlan.title,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: smallSpacing),
                          Text(
                            defaultPlan.description,
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: const Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: smallSpacing),
                          Text(
                            '${defaultPlan.type} - ${defaultPlan.formattedDuration}',
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: mediumSpacing),
                          Text(
                            '包含：${defaultPlan.workoutSegments.map((segment) => segment.title).join('、')}',
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: const Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: smallSpacing),
                          Text(
                            '总轮数：${defaultPlan.totalRounds}轮',
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: mediumSpacing),
                
                // 开始按钮
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => _startWorkout(context, defaultPlan),
                    child: Text(
                      '开始训练',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        }
      ),
    );
  }
}