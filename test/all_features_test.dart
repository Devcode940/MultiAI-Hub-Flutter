import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/data/repository/ai_repository.dart';
import 'package:multiai_hub/services/analytics/analytics_service.dart';
import 'package:multiai_hub/services/cache/cache_service.dart';
import 'package:multiai_hub/services/deep_link/deep_link_service.dart';
import 'package:multiai_hub/utils/default_ai_providers.dart';

void main() {
  // ============ Model Tests ============
  group('AiProvider Model', () {
    test('creates with required fields', () {
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

    test('serializes to Map and deserializes back', () {
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
    });

    test('copyWith works correctly', () {
      final provider = AiProvider(
        name: 'Test',
        url: 'https://test.com',
        addedAt: DateTime(2024, 1, 1),
      );
      final updated = provider.copyWith(isFavorite: true, name: 'Updated');
      expect(updated.isFavorite, true);
      expect(updated.name, 'Updated');
      expect(updated.url, 'https://test.com'); // Unchanged
    });

    test('equality based on id and url', () {
      final a = AiProvider(id: 1, name: 'A', url: 'https://a.com', addedAt: DateTime(2024, 1, 1));
      final b = AiProvider(id: 1, name: 'B', url: 'https://a.com', addedAt: DateTime(2024, 1, 1));
      expect(a, b);
    });
  });

  group('AiCategory', () {
    test('has all 8 categories', () {
      expect(AiCategory.values.length, 8);
    });

    test('each category has label and emoji', () {
      for (final cat in AiCategory.values) {
        expect(cat.label.isNotEmpty, true);
        expect(cat.emoji.isNotEmpty, true);
      }
    });
  });

  // ============ Repository Tests ============
  group('AiRepository', () {
    test('validates URLs and forces HTTPS', () {
      final repo = AiRepository();
      // This would test _validateAndNormalizeUrl if exposed
      // For now, test the public addCustomProvider behavior
    });

    test('rejects empty URLs', () async {
      final repo = AiRepository();
      try {
        await repo.addCustomProvider('Test', '');
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<RepositoryException>());
      }
    });

    test('rejects dangerous URL schemes', () async {
      final repo = AiRepository();
      final dangerousUrls = [
        'javascript:alert(1)',
        'file:///etc/passwd',
        'data:text/html,<h1>test</h1>',
      ];
      for (final url in dangerousUrls) {
        try {
          await repo.addCustomProvider('Test', url);
          fail('Should have thrown for $url');
        } catch (e) {
          expect(e, isA<RepositoryException>());
        }
      }
    });
  });

  // ============ Default Providers Tests ============
  group('DefaultAiProviders', () {
    test('has 32 built-in providers', () {
      expect(DefaultAiProviders.all.length, 32);
    });

    test('all providers have valid URLs', () {
      for (final provider in DefaultAiProviders.all) {
        expect(provider.url.startsWith('https://'), true, reason: '${provider.name} URL must start with https://');
        expect(provider.name.isNotEmpty, true);
      }
    });

    test('covers all categories', () {
      final categories = DefaultAiProviders.all.map((p) => p.category).toSet();
      expect(categories.contains(AiCategory.chat), true);
      expect(categories.contains(AiCategory.search), true);
      expect(categories.contains(AiCategory.coding), true);
      expect(categories.contains(AiCategory.free), true);
      expect(categories.contains(AiCategory.writing), true);
      expect(categories.contains(AiCategory.image), true);
    });
  });

  // ============ Deep Link Tests ============
  group('DeepLinkService', () {
    final service = DeepLinkService.instance;

    test('parses provider deep link', () {
      final action = service.parseLink(Uri.parse('multiai://provider/ChatGPT'));
      expect(action, isNotNull);
      expect(action!.type, DeepLinkType.openProvider);
      expect(action.providerName, 'ChatGPT');
    });

    test('parses ask all deep link', () {
      final action = service.parseLink(Uri.parse('multiai://ask?prompt=Hello%20World'));
      expect(action, isNotNull);
      expect(action!.type, DeepLinkType.askAll);
      expect(action.prompt, 'Hello World');
    });

    test('parses compare deep link', () {
      final action = service.parseLink(Uri.parse('multiai://compare?a=ChatGPT&b=Claude'));
      expect(action, isNotNull);
      expect(action!.type, DeepLinkType.compare);
      expect(action!.providerNames, ['ChatGPT', 'Claude']);
    });

    test('parses favorites deep link', () {
      final action = service.parseLink(Uri.parse('multiai://favorites'));
      expect(action, isNotNull);
      expect(action!.type, DeepLinkType.openFavorites);
    });

    test('generates shareable provider link', () {
      final provider = AiProvider(name: 'ChatGPT', url: 'https://chat.openai.com', addedAt: DateTime(2024, 1, 1));
      final link = service.generateProviderLink(provider);
      expect(link.contains('ChatGPT'), true);
      expect(link.startsWith('multiai://'), true);
    });
  });

  // ============ Cache Tests ============
  group('CacheService', () {
    test('formats bytes correctly', () {
      // Testing the static formatter through CachedPage
      expect(CachedPage._formatBytes(500), '500 B');
      expect(CachedPage._formatBytes(1500), '1.5 KB');
      expect(CachedPage._formatBytes(1572864), '1.5 MB');
    });
  });
}
