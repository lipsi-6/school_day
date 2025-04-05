import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String category;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed; // 注意这里是可为空的

  const CategoryButton({
    super.key,
    required this.category,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey, // 未禁用时用指定颜色
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon),
        label: Text(category),
        onPressed: onPressed,
      ),
    );
  }
}