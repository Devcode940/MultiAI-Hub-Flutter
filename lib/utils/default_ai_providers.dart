import 'package:multiai_hub/data/models/ai_provider.dart';

/// Default AI providers seeded on first app launch - mirrors Kotlin DefaultAiProviders.kt
class DefaultAiProviders {
  static List<AiProvider> get all => [
        // === CHAT ===
        AiProvider(
          name: 'ChatGPT',
          url: 'https://chat.openai.com',
          category: AiCategory.chat,
          description: 'OpenAI\'s conversational AI',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Claude',
          url: 'https://claude.ai',
          category: AiCategory.chat,
          description: 'Anthropic\'s AI assistant',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Gemini',
          url: 'https://gemini.google.com',
          category: AiCategory.chat,
          description: 'Google\'s multimodal AI',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Grok',
          url: 'https://grok.x.ai',
          category: AiCategory.chat,
          description: 'xAI\'s conversational AI',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'DeepSeek',
          url: 'https://chat.deepseek.com',
          category: AiCategory.chat,
          description: 'DeepSeek AI chat',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Qwen',
          url: 'https://tongyi.aliyun.com/qianwen',
          category: AiCategory.chat,
          description: 'Alibaba\'s Qwen AI',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Mistral',
          url: 'https://chat.mistral.ai',
          category: AiCategory.chat,
          description: 'Mistral AI chat',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Pi',
          url: 'https://pi.ai',
          category: AiCategory.chat,
          description: 'Inflection AI\'s Pi',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Poe',
          url: 'https://poe.com',
          category: AiCategory.chat,
          description: 'Multi-model chat platform',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Character.AI',
          url: 'https://character.ai',
          category: AiCategory.chat,
          description: 'AI character conversations',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Kimi',
          url: 'https://kimi.moonshot.cn',
          category: AiCategory.chat,
          description: 'Moonshot AI assistant',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Meta AI',
          url: 'https://www.meta.ai',
          category: AiCategory.chat,
          description: 'Meta\'s AI assistant',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Cohere Coral',
          url: 'https://coral.cohere.com',
          category: AiCategory.chat,
          description: 'Cohere\'s enterprise AI',
          addedAt: DateTime.now(),
        ),

        // === SEARCH ===
        AiProvider(
          name: 'Perplexity',
          url: 'https://www.perplexity.ai',
          category: AiCategory.search,
          description: 'AI-powered search engine',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'You.com',
          url: 'https://you.com',
          category: AiCategory.search,
          description: 'AI search assistant',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Phind',
          url: 'https://www.phind.com',
          category: AiCategory.search,
          description: 'AI search for developers',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Microsoft Copilot',
          url: 'https://copilot.microsoft.com',
          category: AiCategory.search,
          description: 'Microsoft\'s AI assistant',
          addedAt: DateTime.now(),
        ),

        // === CODING ===
        AiProvider(
          name: 'Blackbox AI',
          url: 'https://www.blackbox.ai',
          category: AiCategory.coding,
          description: 'AI code generation',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Cursor',
          url: 'https://cursor.sh',
          category: AiCategory.coding,
          description: 'AI-powered code editor',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Replit AI',
          url: 'https://replit.com',
          category: AiCategory.coding,
          description: 'AI coding in the cloud',
          addedAt: DateTime.now(),
        ),

        // === FREE ===
        AiProvider(
          name: 'HuggingChat',
          url: 'https://huggingface.co/chat',
          category: AiCategory.free,
          description: 'Free open-source AI chat',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'OpenRouter',
          url: 'https://openrouter.ai',
          category: AiCategory.free,
          description: 'Multi-model API router',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'LMSYS Arena',
          url: 'https://chat.lmsys.org',
          category: AiCategory.free,
          description: 'LLM benchmark arena',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'DuckDuckGo AI',
          url: 'https://duckduckgo.com/?q=DuckDuckGo+AI+chat&ia=chat',
          category: AiCategory.free,
          description: 'Private AI chat',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Groq',
          url: 'https://console.groq.com',
          category: AiCategory.free,
          description: 'Ultra-fast LLM inference',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Together AI',
          url: 'https://www.together.ai',
          category: AiCategory.free,
          description: 'Open-source AI platform',
          addedAt: DateTime.now(),
        ),

        // === WRITING ===
        AiProvider(
          name: 'NotebookLM',
          url: 'https://notebooklm.google.com',
          category: AiCategory.writing,
          description: 'Google\'s notebook AI',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Gamma',
          url: 'https://gamma.app',
          category: AiCategory.writing,
          description: 'AI presentation maker',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'ChatPDF',
          url: 'https://www.chatpdf.com',
          category: AiCategory.writing,
          description: 'Chat with PDF documents',
          addedAt: DateTime.now(),
        ),

        // === IMAGE ===
        AiProvider(
          name: 'Leonardo AI',
          url: 'https://leonardo.ai',
          category: AiCategory.image,
          description: 'AI image generation',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Ideogram',
          url: 'https://ideogram.ai',
          category: AiCategory.image,
          description: 'AI text-in-image generation',
          addedAt: DateTime.now(),
        ),
        AiProvider(
          name: 'Flux AI',
          url: 'https://flux1.ai',
          category: AiCategory.image,
          description: 'Flux image generation',
          addedAt: DateTime.now(),
        ),
      ];
}
