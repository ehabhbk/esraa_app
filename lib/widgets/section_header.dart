import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              child: const Text('عرض الكل'),
            ),
        ],
      ),
    );
  }
}
