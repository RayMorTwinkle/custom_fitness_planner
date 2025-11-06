import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fitness_plan.dart';
import '../providers/fitness_plan_provider.dart';
import 'edit_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  PlansScreenState createState() => PlansScreenState();
}

class PlansScreenState extends State<PlansScreen> {
  // 定义常量 (保持不变)
  static const double gridPadding = 16.0;
  static const double gridSpacing = 16.0;

  void _editPlan(int index, FitnessPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlanScreen(plan: plan),
      ),
    );
  }

  void _toggleDefaultPlan(FitnessPlan plan) {
    final provider = Provider.of<FitnessPlanProvider>(context, listen: false);
    provider.toggleDefaultPlan(plan);
  }

  @override
  Widget build(BuildContext context) {
    // --- 优化点 1: 提前计算响应式布局参数 ---
    // 在 build 方法中（Consumer 之外）计算一次即可，避免在 GridView 内部重复计算。
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 500;
    final isMediumScreen = screenSize.width >= 500 && screenSize.width < 1200;

    final int crossAxisCount = isSmallScreen ? 1 : (isMediumScreen ? 2 : 3);
    final double childAspectRatio = isSmallScreen ? 2.0 : 1.5;

    // --- 优化点 2: 提前计算卡片宽度 ---
    // 移除了 LayoutBuilder，我们在这里直接计算卡片宽度。
    // (屏幕总宽 - 两边padding - (N-1)个间距) / N
    final double cardWidth = (screenSize.width -
            (gridPadding * 2) -
            (gridSpacing * (crossAxisCount - 1))) /
        crossAxisCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('健身计划'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPlanScreen(plan: null)),
              );
            },
          ),
        ],
      ),
      // Consumer 只用于获取列表，它不会在 toggleDefaultPlan 时重建
      body: Consumer<FitnessPlanProvider>(
        builder: (context, provider, child) {
          final fitnessPlans = provider.fitnessPlans;

          return Padding(
            padding: const EdgeInsets.all(gridPadding),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: gridSpacing,
                mainAxisSpacing: gridSpacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: fitnessPlans.length,
              itemBuilder: (context, index) {
                final plan = fitnessPlans[index];

                // --- 优化点 3: 提取卡片为独立 Widget ---
                // 将 plan、计算好的 cardWidth 和回调函数传递下去。
                // _PlanCard 内部将使用 Selector 来实现局部刷新。
                return _PlanCard(
                  plan: plan,
                  cardWidth: cardWidth,
                  onToggleDefault: () => _toggleDefaultPlan(plan),
                  onEdit: () => _editPlan(index, plan),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- 优化点 4: 提取独立的卡片 Widget ---
// 这个 Widget 只负责渲染单个卡片。
class _PlanCard extends StatelessWidget {
  // 卡片相关的常量可以移到这里
  static const double cardElevation = 4.0;
  static const double cardRadius = 12.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;

  final FitnessPlan plan;
  final double cardWidth;
  final VoidCallback onToggleDefault;
  final VoidCallback onEdit;

  const _PlanCard({
    // Key is important for list performance
    required this.plan,
    required this.cardWidth,
    required this.onToggleDefault,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // --- 优化点 5: 使用 Selector 进行精细化重建 ---
    // Selector 只会监听 `isDefaultPlan(plan)` 这个 bool 值的变化。
    // 当 provider 通知更新时，只有 `isDefault` 状态发生变化的卡片
    // (即新的默认卡片和旧的默认卡片) 才会重建这个 builder，
    // GridView 和其他所有卡片都不会重建，性能极大提升。
    return Selector<FitnessPlanProvider, bool>(
      selector: (_, provider) => provider.isDefaultPlan(plan),
      builder: (context, isDefault, child) {
        
        // --- 优化点 6: 响应式计算移入 ---
        // 响应式计算逻辑（原 LayoutBuilder 中的内容）移到这里。
        // 因为这个 builder 只有在状态变化时才执行，所以开销很小。
        final isSmallCard = cardWidth < 250;
        final isMediumCard = cardWidth >= 250 && cardWidth < 400;

        final cardPadding = isSmallCard
            ? smallSpacing * 1.5
            : (isMediumCard ? mediumSpacing : largeSpacing * 1.5);
        final iconSize =
            isSmallCard ? 36.0 : (isMediumCard ? 40.0 : 48.0);
        final iconInnerSize =
            isSmallCard ? 20.0 : (isMediumCard ? 24.0 : 32.0);
        final starIconSize =
            isSmallCard ? 12.0 : (isMediumCard ? 14.0 : 18.0);

        final subtitleFontSize =
            isSmallCard ? 14.0 : (isMediumCard ? 16.0 : 24.0);
        final bodyFontSize =
            isSmallCard ? 12.0 : (isMediumCard ? 14.0 : 18.0);
        final smallFontSize =
            isSmallCard ? 10.0 : (isMediumCard ? 12.0 : 16.0);

        return InkWell(
          onTap: onToggleDefault,
          borderRadius: BorderRadius.circular(cardRadius), // 匹配 Card 圆角
          child: Card(
            elevation: cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Stack(
                children: [
                  // 主要内容
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题行
                      Row(
                        children: [
                          _buildPlanIcon(iconSize, iconInnerSize),
                          SizedBox(width: mediumSpacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  plan.title,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w600,
                                    // 响应 isDefault 状态
                                    color: isDefault
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF333333),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // 保持一个固定的间距，避免徽章出现时跳动
                                SizedBox(height: smallSpacing),

                                // --- 优化点 7: 使用 AnimatedCrossFade 优化动画和排版 ---
                                // 解决了"默认"徽章出现/消失时的布局抖动（Jank）问题。
                                // 它会平滑地动画高度和透明度。
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 200),
                                  // firstChild 是徽章
                                  firstChild: _buildDefaultBadge(
                                      starIconSize,
                                      smallFontSize,
                                      smallSpacing),
                                  // secondChild 是一个零高度的占位符
                                  secondChild: SizedBox.shrink(),
                                  // 根据 isDefault 状态切换
                                  crossFadeState: isDefault
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  // 确保对齐
                                  alignment: Alignment.centerLeft,
                                  layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                                    // 优化对齐，防止切换时轻微移动
                                    return Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        Positioned(key: bottomKey, child: bottomChild),
                                        Positioned(key: topKey, child: topChild),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: smallSpacing),

                      // 计划描述
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: bodyFontSize * 2.5, // 限制最大高度为2.5行
                        ),
                        child: Text(
                          plan.description,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: isDefault
                                ? Colors.blue[600]
                                : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: smallSpacing),

                      // 计划详情
                      Text(
                        '${plan.totalRounds}轮 × ${plan.formattedDuration}',
                        style: TextStyle(
                          fontSize: smallFontSize,
                          color: isDefault
                              ? Colors.blue[500]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  // 编辑按钮 - 定位在右上角
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: onEdit, // 使用传入的回调
                      icon: Icon(Icons.edit, size: iconInnerSize),
                      color: Colors.blue,
                      tooltip: '编辑计划',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: iconInnerSize + 16,
                        minHeight: iconInnerSize + 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 提取 "默认" 徽章为一个私有方法，保持 build 方法清洁
  Widget _buildDefaultBadge(
      double starIconSize, double smallFontSize, double smallSpacing) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: smallSpacing * 2,
        vertical: smallSpacing,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(starIconSize * 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: starIconSize,
            color: Colors.white,
          ),
          SizedBox(width: smallSpacing),
          Text(
            '默认',
            style: TextStyle(
              fontSize: smallFontSize,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 提取图标为一个私有方法
  Widget _buildPlanIcon(double iconSize, double iconInnerSize) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.green, // 使用绿色替换蓝色
        borderRadius: BorderRadius.circular(iconSize * 0.2),
      ),
      child: Icon(
        Icons.fitness_center,
        color: Colors.white,
        size: iconInnerSize,
      ),
    );
  }
}