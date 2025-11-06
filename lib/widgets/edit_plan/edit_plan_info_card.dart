import 'package:flutter/material.dart';

class EditPlanInfoCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController totalRoundsController;
  final TextEditingController restBetweenRoundsController;
  final bool isSmallScreen;

  const EditPlanInfoCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.totalRoundsController,
    required this.restBetweenRoundsController,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    // 响应式尺寸计算
    final double cardPadding = isSmallScreen ? 12.0 : 16.0;
    final double titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final double spacingValue = isSmallScreen ? 8.0 : 12.0;
    final double rowSpacing = isSmallScreen ? 8.0 : 12.0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '计划信息',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: spacingValue * 2),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '计划标题*',
                border: OutlineInputBorder(),
                hintText: '例如：全身训练计划',
              ),
            ),
            SizedBox(height: spacingValue),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '计划描述',
                border: OutlineInputBorder(),
                hintText: '例如：45分钟全身锻炼',
              ),
            ),
            SizedBox(height: spacingValue),
            // 根据屏幕尺寸切换布局
            isSmallScreen
                ? Column(
                    children: [
                      TextField(
                        controller: totalRoundsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '总轮数',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: spacingValue),
                      TextField(
                        controller: restBetweenRoundsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '轮间休息(秒)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: totalRoundsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '总轮数',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: rowSpacing),
                      Expanded(
                        child: TextField(
                          controller: restBetweenRoundsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '轮间休息(秒)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}