import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/filter_type.dart';

class FilterSelector extends StatelessWidget {
  final FilterType selected;
  final ValueChanged<FilterType> onSelected;

  const FilterSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FilterType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = FilterType.values[index];
          final isActive = filter == selected;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? AppColors.accentPink
                          : Colors.white54,
                      width: isActive ? 2.5 : 1.5,
                    ),
                    gradient: LinearGradient(
                      colors: _swatchColors(filter),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  filter.label,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.accentPink
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Color> _swatchColors(FilterType filter) {
    switch (filter) {
      case FilterType.none:
        return [Colors.grey.shade700, Colors.grey.shade400];
      case FilterType.blackAndWhite:
        return [Colors.black, Colors.white];
      case FilterType.vintage:
        return [const Color(0xFF7B5B3A), const Color(0xFFD8B36A)];
      case FilterType.warm:
        return [Colors.deepOrange, Colors.amber];
      case FilterType.cool:
        return [Colors.blue, Colors.cyanAccent];
      case FilterType.beauty:
        return [Colors.pinkAccent, Colors.white];
    }
  }
}
