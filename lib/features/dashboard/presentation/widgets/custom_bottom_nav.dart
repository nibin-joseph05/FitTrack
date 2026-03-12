import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.cardDark,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 20,
      height: 65,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home,
                color:
                    currentIndex == 0 ? AppColors.primary : AppColors.textHint,
                size: 28),
            onPressed: () => onTap(0),
          ),
          const SizedBox(width: 48),
          IconButton(
            icon: Icon(currentIndex == 1 ? Icons.person : Icons.person_outline,
                color:
                    currentIndex == 1 ? AppColors.primary : AppColors.textHint,
                size: 28),
            onPressed: () => onTap(1),
          ),
        ],
      ),
    );
  }
}
