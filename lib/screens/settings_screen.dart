import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _segmentDuration = 45.0; // 默认片段时长（秒）
  double _restDuration = 20.0;    // 默认休息时长（秒）
  late TextEditingController _segmentDurationController;
  late TextEditingController _restDurationController;

  // 响应式布局变量
  late bool _isSmallScreen;
  late bool _isMediumScreen;
  late double _titleFontSize;
  late double _subtitleFontSize;
  late double _bodyFontSize;
  late double _smallFontSize;
  late double _smallSpacing;
  late double _mediumSpacing;
  late double _largeSpacing;
  late double _paddingValue;
  late double _cardPadding;
  late double _iconSize;

  @override
  void initState() {
    super.initState();
    _segmentDurationController = TextEditingController();
    _restDurationController = TextEditingController();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateResponsiveLayout();
  }

  // 计算响应式布局参数
  void _calculateResponsiveLayout() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    _isSmallScreen = screenWidth < 600;
    _isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
    
    _titleFontSize = _isSmallScreen ? 24.0 : _isMediumScreen ? 28.0 : 32.0;
    _subtitleFontSize = _isSmallScreen ? 16.0 : _isMediumScreen ? 18.0 : 20.0;
    _bodyFontSize = _isSmallScreen ? 14.0 : _isMediumScreen ? 16.0 : 18.0;
    _smallFontSize = _isSmallScreen ? 12.0 : _isMediumScreen ? 14.0 : 16.0;
    
    _smallSpacing = screenHeight * 0.008;
    _mediumSpacing = screenHeight * 0.016;
    _largeSpacing = screenHeight * 0.024;
    
    _paddingValue = _isSmallScreen ? 12.0 : _isMediumScreen ? 16.0 : 20.0;
    _cardPadding = _isSmallScreen ? 16.0 : _isMediumScreen ? 20.0 : 24.0;
    _iconSize = _isSmallScreen ? 24.0 : _isMediumScreen ? 26.0 : 28.0;
  }

  // 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _segmentDuration = prefs.getDouble('segmentDuration') ?? 45.0;
      _restDuration = prefs.getDouble('restDuration') ?? 20.0;
      _updateTextControllers();
    });
  }

  // 更新文本控制器
  void _updateTextControllers() {
    _segmentDurationController.text = _segmentDuration.round().toString();
    _restDurationController.text = _restDuration.round().toString();
  }

  // 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('segmentDuration', _segmentDuration);
    await prefs.setDouble('restDuration', _restDuration);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _segmentDurationController.dispose();
    _restDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(_paddingValue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 设置标题
                Row(
                  children: [
                    Icon(Icons.settings, color: const Color(0xFF4CAF50), size: _iconSize),
                    SizedBox(width: _smallSpacing),
                    Text(
                      '训练设置',
                      style: TextStyle(
                        fontSize: _titleFontSize, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF4CAF50)
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _largeSpacing),
                
                // 片段时长设置
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '片段时长 (秒)',
                          style: TextStyle(fontSize: _subtitleFontSize, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: _smallSpacing),
                        
                        // 在小屏幕上使用垂直布局，大屏幕上使用水平布局
                        _isSmallScreen ? Column(
                          children: [
                            Slider(
                              value: _segmentDuration.clamp(20.0, 120.0),
                              min: 20.0,
                              max: 120.0,
                              divisions: 10,
                              label: _segmentDuration.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _segmentDuration = value;
                                  _updateTextControllers();
                                });
                              },
                            ),
                            SizedBox(height: _mediumSpacing),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              padding: EdgeInsets.symmetric(horizontal: _smallSpacing * 1.5, vertical: _smallSpacing),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(_smallSpacing * 2),
                              ),
                              child: TextFormField(
                                controller: _segmentDurationController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _bodyFontSize),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue != null && doubleValue >= 5.0 && doubleValue <= 300.0) {
                                    setState(() {
                                      _segmentDuration = doubleValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ) : Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _segmentDuration.clamp(20.0, 120.0),
                                min: 20.0,
                                max: 120.0,
                                divisions: 10,
                                label: _segmentDuration.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _segmentDuration = value;
                                    _updateTextControllers();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: _mediumSpacing),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              padding: EdgeInsets.symmetric(horizontal: _smallSpacing * 1.5, vertical: _smallSpacing),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(_smallSpacing * 2),
                              ),
                              child: TextFormField(
                                controller: _segmentDurationController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _bodyFontSize),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue != null && doubleValue >= 5.0 && doubleValue <= 300.0) {
                                    setState(() {
                                      _segmentDuration = doubleValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: _smallSpacing),
                        Text(
                          '当前值: ${_segmentDuration.round()} 秒',
                          style: TextStyle(color: Colors.grey[600], fontSize: _smallFontSize),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: _mediumSpacing),
                
                // 休息时长设置
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '休息时长 (秒)',
                          style: TextStyle(fontSize: _subtitleFontSize, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: _smallSpacing),
                        
                        // 在小屏幕上使用垂直布局，大屏幕上使用水平布局
                        _isSmallScreen ? Column(
                          children: [
                            Slider(
                              value: _restDuration.clamp(10.0, 100.0),
                              min: 10.0,
                              max: 100.0,
                              divisions: 9,
                              label: _restDuration.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _restDuration = value;
                                  _updateTextControllers();
                                });
                              },
                            ),
                            SizedBox(height: _mediumSpacing),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              padding: EdgeInsets.symmetric(horizontal: _smallSpacing * 1.5, vertical: _smallSpacing),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(_smallSpacing * 2),
                              ),
                              child: TextFormField(
                                controller: _restDurationController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _bodyFontSize),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue != null && doubleValue >= 3.0 && doubleValue <= 200.0) {
                                    setState(() {
                                      _restDuration = doubleValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ) : Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _restDuration.clamp(10.0, 100.0),
                                min: 10.0,
                                max: 100.0,
                                divisions: 9,
                                label: _restDuration.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _restDuration = value;
                                    _updateTextControllers();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: _mediumSpacing),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              padding: EdgeInsets.symmetric(horizontal: _smallSpacing * 1.5, vertical: _smallSpacing),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(_smallSpacing * 2),
                              ),
                              child: TextFormField(
                                controller: _restDurationController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _bodyFontSize),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue != null && doubleValue >= 3.0 && doubleValue <= 200.0) {
                                    setState(() {
                                      _restDuration = doubleValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: _smallSpacing),
                        Text(
                          '当前值: ${_restDuration.round()} 秒',
                          style: TextStyle(color: Colors.grey[600], fontSize: _smallFontSize),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: _largeSpacing),
                
                // 保存按钮
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: Icon(Icons.save, size: _iconSize),
                    label: Text('保存设置', style: TextStyle(fontSize: _bodyFontSize)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: _mediumSpacing * 2, vertical: _mediumSpacing),
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