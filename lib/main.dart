import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_navigation.dart';
import 'providers/fitness_plan_provider.dart';

void main() {
  runApp(const MyApp());
}

// 优化：将 ThemeData 提取为 final 变量 (或 static final)
// 1. 性能：这可以防止 ThemeData 在 MyApp 重建时不必要地重新创建。
// 2. 性能：在 ThemeData 内部尽可能多地使用 `const` 构造函数。
// 3. 性能：使用 `Colors.black.withAlpha(int)` 代替 `Colors.black.withValues(alpha: double)`
//    因为 `withAlpha` 是 const。
// 4. 性能：使用 `Colors.grey.shade50` 代替 `Colors.grey[50]`，因为 `shade` 是 const。
final ThemeData _appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4CAF50), // 清新的绿色主题
    brightness: Brightness.light,
  ),
  // 现代化的卡片阴影
  cardTheme: CardThemeData(
    elevation: 4,
    shadowColor: Colors.black.withAlpha(26), // 0.1 * 255 = 25.5 -> 26
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  // 现代化的按钮样式
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withAlpha(51), // 0.2 * 255 = 51
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  // 现代化的AppBar样式
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF333333),
    elevation: 1,
    shadowColor: Colors.black.withAlpha(13), // 0.05 * 255 = 12.75 -> 13
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF333333),
    ),
  ),
  // 现代化的输入框样式
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50, // const
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none, // const
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none, // const
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2), // const
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // const
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FitnessPlanProvider()),
      ],
      child: MaterialApp(
        title: '自定义健身计划器',
        // 优化：引用预先构建的 ThemeData 实例
        theme: _appTheme,
        // 优化：如果 MainNavigation 构造函数是 const，则使用 const
        // 这可以防止 MainNavigation 在 MyApp 重建时不必要地重建。
        home: const MainNavigation(),
      ),
    );
  }
}