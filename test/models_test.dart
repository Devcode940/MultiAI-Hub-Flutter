import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/data/database/app_database.dart';

void main() {
  group('AiProvider Model Tests', () {
    test('AiProvider can be created with required fields', () {
      final provider = AiProvider(
        name: 'ChatGPT',
        url: 'https://chat.openai.com',
        category: AiCategory.chat,
        addedAt: DateTime(2024, 1, 1),
      );
      expect(provider.name, 'ChatGPT');
      expect(provider.url, 'https://chat.openai.com');
      expect(provider.category, AiCategory.chat);
      expect(provider.isFavorite, false);
      expect(provider.isCustom, false);
    });

    test('AiProvider can be converted to Map and back', () {
      final provider = AiProvider(
        id: 1,
        name: 'Claude',
        url: 'https://claude.ai',
        category: AiCategory.chat,
        isFavorite: true,
        addedAt: DateTime(2024, 1, 1),
      );
      final map = provider.toMap();
      final restored = AiProvider.fromMap(map);
      expect(restored.name, provider.name);
      expect(restored.url, provider.url);
      expect(restored.category, provider.category);
      expect(restored.isFavorite, provider.isFavorite);
    });

    test('AiCategory has all expected values', () {
      expect(AiCategory.values.length, 8);
      expect(AiCategory.chat.label, 'Chat');
      expect(AiCategory.coding.label, 'Coding');
      expect(AiCategory.image.label, 'Image');
      expect(AiCategory.favorite.label, 'Favorite');
    });

    test('AiProvider copyWith works correctly', () {
      final provider = AiProvider(
        name: 'Test',
        url: 'https://test.com',
        category: AiCategory.chat,
        addedAt: DateTime(2024, 1, 1),
      );
      final updated = provider.copyWith(isFavorite: true);
      expect(updated.isFavorite, true);
      expect(updated.name, 'Test');
    });
  });
}
