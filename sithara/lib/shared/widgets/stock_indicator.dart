import 'package:flutter/material.dart';

class StockIndicator extends StatelessWidget {
  final String status; // "in" | "out"
  final bool interactive;
  final ValueChanged<String>? onChanged;

  const StockIndicator({
    super.key,
    required this.status,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isIn = status == 'in';
    final color = isIn ? Colors.green : Colors.red;
    final label = isIn ? 'In Stock' : 'Out of Stock';

    if (!interactive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    return GestureDetector(
      onTap: () => onChanged?.call(isIn ? 'out' : 'in'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.swap_horiz, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
