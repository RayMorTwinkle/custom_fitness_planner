import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flowfit/models/workout_segment.dart';

class EditWorkoutSegmentCard extends StatelessWidget {
  final WorkoutSegment segment;
  final int index;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController durationController;
  final Function(int) onPickImage;
  final Function(int) onRemoveImage;
  final Function(int) onDelete;
  final bool canDelete;
  final Function(int, WorkoutSegment) onUpdate;
  final bool isSmallScreen;

  const EditWorkoutSegmentCard({
    super.key,
    required this.segment,
    required this.index,
    required this.titleController,
    required this.descriptionController,
    required this.durationController,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onDelete,
    required this.canDelete,
    required this.onUpdate,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    // 响应式尺寸计算
    final double cardMargin = isSmallScreen ? 8.0 : 12.0;
    final double cardPadding = isSmallScreen ? 8.0 : 12.0;
    final double iconSize = isSmallScreen ? 14.0 : 16.0;
    final double titleFontSize = isSmallScreen ? 12.0 : 14.0;
    final double spacingValue = isSmallScreen ? 8.0 : 12.0;
    final double imageSize = isSmallScreen ? 80.0 : 100.0;
    final double buttonIconSize = isSmallScreen ? 16.0 : 18.0;
    final double buttonHeight = isSmallScreen ? 36.0 : 40.0;
    
    return Card(
      margin: EdgeInsets.only(bottom: cardMargin),
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, size: iconSize, color: Colors.green[700]),
                    SizedBox(width: cardPadding / 2),
                    Text(
                      '训练片段 ${index + 1}',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                // 删除按钮
                if (canDelete)
                  IconButton(
                    onPressed: () => onDelete(index),
                    icon: Icon(Icons.delete, size: iconSize + 2, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    tooltip: '删除训练片段',
                  ),
              ],
            ),
            SizedBox(height: spacingValue),
            
            // 图片选择区域 - 根据屏幕尺寸切换布局
            isSmallScreen
                ? Column(
                    children: [
                      // 图片预览
                      if (segment.imagePath.isNotEmpty)
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(segment.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.grey[500], size: 20),
                                      SizedBox(height: 2),
                                      Text('加载失败', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, color: Colors.grey[500], size: 24),
                              SizedBox(height: 2),
                              Text('暂无图片', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      
                      SizedBox(height: spacingValue),
                      
                      // 图片选择按钮
                      ElevatedButton.icon(
                        onPressed: () => onPickImage(index),
                        icon: Icon(Icons.photo_library, size: buttonIconSize),
                        label: Text(segment.imagePath.isEmpty ? '选择图片' : '更换图片'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, buttonHeight),
                        ),
                      ),
                      if (segment.imagePath.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => onRemoveImage(index),
                          icon: Icon(Icons.delete, size: buttonIconSize - 2, color: Colors.red),
                          label: Text('删除图片', style: TextStyle(color: Colors.red, fontSize: 10)),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      // 图片预览
                      if (segment.imagePath.isNotEmpty)
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(segment.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.grey[500], size: 24),
                                      SizedBox(height: 4),
                                      Text('加载失败', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, color: Colors.grey[500], size: 32),
                              SizedBox(height: 4),
                              Text('暂无图片', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      
                      SizedBox(width: spacingValue),
                      
                      // 图片选择按钮
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => onPickImage(index),
                              icon: Icon(Icons.photo_library, size: buttonIconSize),
                              label: Text(segment.imagePath.isEmpty ? '选择图片' : '更换图片'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, buttonHeight),
                              ),
                            ),
                            if (segment.imagePath.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => onRemoveImage(index),
                                icon: Icon(Icons.delete, size: buttonIconSize - 2, color: Colors.red),
                                label: Text('删除图片', style: TextStyle(color: Colors.red, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
            
            SizedBox(height: spacingValue),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '动作名称',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                onUpdate(index, segment.copyWith(title: value));
              },
            ),
            SizedBox(height: spacingValue / 2),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '动作描述',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                onUpdate(index, segment.copyWith(description: value));
              },
            ),
            SizedBox(height: spacingValue / 2),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '时长(秒)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}