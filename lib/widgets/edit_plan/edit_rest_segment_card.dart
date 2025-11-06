import 'package:flutter/material.dart';
import 'package:flowfit/models/rest_segment.dart';

class EditRestSegmentCard extends StatelessWidget {
  final RestSegment segment;
  final int index;
  final TextEditingController durationController;

  const EditRestSegmentCard({
    super.key,
    required this.segment,
    required this.index,
    required this.durationController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  '休息片段 ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '休息时长(秒)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}