import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';

/// AI Provider card widget - mirrors Kotlin AiCard.kt
class AiCard extends StatelessWidget {
  final AiProvider provider;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const AiCard({
    super.key,
    required this.provider,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with category color
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(colorScheme).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    provider.category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Provider name
              Text(
                provider.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Category label
              Text(
                provider.category.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),

              // Favorite indicator
              if (provider.isFavorite)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.star,
                    size: 16,
                    color: colorScheme.tertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ColorScheme colorScheme) {
    switch (provider.category) {
      case AiCategory.chat:
        return colorScheme.primary;
      case AiCategory.coding:
        return colorScheme.tertiary;
      case AiCategory.writing:
        return colorScheme.secondary;
      case AiCategory.image:
        return colorScheme.error;
      case AiCategory.search:
        return colorScheme.tertiaryContainer;
      case AiCategory.free:
        return colorScheme.primaryContainer;
      case AiCategory.custom:
        return colorScheme.surfaceVariant;
      case AiCategory.favorite:
        return colorScheme.tertiary;
    }
  }
}
