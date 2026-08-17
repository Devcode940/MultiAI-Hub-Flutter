import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';

/// Pipeline step model - represents one step in an AI chain
class PipelineStep {
  final String id;
  final AiProvider provider;
  final String promptTemplate;
  final Duration? delayBetween;
  final bool usePreviousOutput;

  const PipelineStep({
    required this.id,
    required this.provider,
    required this.promptTemplate,
    this.delayBetween,
    this.usePreviousOutput = true,
  });

  /// Build the actual prompt by injecting previous output
  String buildPrompt({String? previousOutput}) {
    var prompt = promptTemplate;
    if (usePreviousOutput && previousOutput != null) {
      prompt = prompt.replaceAll('{{input}}', previousOutput);
    }
    return prompt;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerId': provider.id,
    'providerName': provider.name,
    'promptTemplate': promptTemplate,
    'usePreviousOutput': usePreviousOutput,
  };
}

/// Pipeline model - a chain of AI steps
class Pipeline {
  final String id;
  final String name;
  final String description;
  final List<PipelineStep> steps;
  final DateTime createdAt;
  bool isRunning;
  int currentStepIndex;

  Pipeline({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.createdAt,
    this.isRunning = false,
    this.currentStepIndex = 0,
  });

  Pipeline copyWith({bool? isRunning, int? currentStepIndex}) => Pipeline(
    id: id,
    name: name,
    description: description,
    steps: steps,
    createdAt: createdAt,
    isRunning: isRunning ?? this.isRunning,
    currentStepIndex: currentStepIndex ?? this.currentStepIndex,
  );

  PipelineStep? get currentStep =>
      currentStepIndex < steps.length ? steps[currentStepIndex] : null;

  bool get isComplete => currentStepIndex >= steps.length;

  double get progress => steps.isEmpty ? 0 : currentStepIndex / steps.length;
}

/// Built-in pipeline templates
class PipelineTemplates {
  static List<Pipeline> get defaults => [
    Pipeline(
      id: 'refine_writing',
      name: 'Refine Writing',
      description: 'Draft with ChatGPT → Refine with Claude → Polish with Grammarly',
      createdAt: DateTime.now(),
      steps: [
        PipelineStep(
          id: 'draft',
          provider: AiProvider(name: 'ChatGPT', url: 'https://chat.openai.com', addedAt: DateTime.now()),
          promptTemplate: 'Write a draft about: {{input}}',
        ),
        PipelineStep(
          id: 'refine',
          provider: AiProvider(name: 'Claude', url: 'https://claude.ai', addedAt: DateTime.now()),
          promptTemplate: 'Refine and improve this text, making it more clear and concise:\n\n{{input}}',
        ),
        PipelineStep(
          id: 'polish',
          provider: AiProvider(name: 'Gemini', url: 'https://gemini.google.com', addedAt: DateTime.now()),
          promptTemplate: 'Final polish - fix grammar, improve flow, and make it publication-ready:\n\n{{input}}',
        ),
      ],
    ),
    Pipeline(
      id: 'code_review',
      name: 'Code Review Pipeline',
      description: 'Analyze with ChatGPT → Security audit with Claude → Optimize',
      createdAt: DateTime.now(),
      steps: [
        PipelineStep(
          id: 'analyze',
          provider: AiProvider(name: 'ChatGPT', url: 'https://chat.openai.com', addedAt: DateTime.now()),
          promptTemplate: 'Analyze this code for bugs and issues:\n\n{{input}}',
        ),
        PipelineStep(
          id: 'security',
          provider: AiProvider(name: 'Claude', url: 'https://claude.ai', addedAt: DateTime.now()),
          promptTemplate: 'Review this code for security vulnerabilities:\n\n{{input}}',
        ),
      ],
    ),
    Pipeline(
      id: 'research',
      name: 'Research Pipeline',
      description: 'Search with Perplexity → Summarize with Claude → Format with ChatGPT',
      createdAt: DateTime.now(),
      steps: [
        PipelineStep(
          id: 'search',
          provider: AiProvider(name: 'Perplexity', url: 'https://www.perplexity.ai', addedAt: DateTime.now()),
          promptTemplate: 'Research: {{input}}',
        ),
        PipelineStep(
          id: 'summarize',
          provider: AiProvider(name: 'Claude', url: 'https://claude.ai', addedAt: DateTime.now()),
          promptTemplate: 'Summarize the key findings from this research:\n\n{{input}}',
        ),
        PipelineStep(
          id: 'format',
          provider: AiProvider(name: 'ChatGPT', url: 'https://chat.openai.com', addedAt: DateTime.now()),
          promptTemplate: 'Format this summary into a well-structured report:\n\n{{input}}',
        ),
      ],
    ),
  ];
}

/// Pipeline screen - create, manage, and run AI chains
class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final List<Pipeline> _pipelines = [];
  final Map<String, String> _stepResults = {};
  Pipeline? _runningPipeline;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pipelines.addAll(PipelineTemplates.defaults);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Pipelines'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showCreatePipelineDialog),
        ],
      ),
      body: _pipelines.isEmpty
          ? _buildEmptyState(theme, colorScheme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pipelines.length,
              itemBuilder: (context, index) {
                final pipeline = _pipelines[index];
                return _buildPipelineCard(pipeline, theme, colorScheme);
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('No pipelines yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Create an AI chain to automate multi-step workflows'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showCreatePipelineDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Pipeline'),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(Pipeline pipeline, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(pipeline.name, style: theme.textTheme.titleMedium),
                ),
                if (pipeline.isRunning)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(pipeline.description, style: theme.textTheme.bodySmall),

            // Step flow visualization
            const SizedBox(height: 16),
            _buildStepFlow(pipeline, colorScheme),

            // Progress bar (if running)
            if (pipeline.isRunning) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pipeline.progress,
                  minHeight: 6,
                ),
              ),
            ],

            // Actions
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPipelineDetails(pipeline),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: pipeline.isRunning ? null : () => _runPipeline(pipeline),
                    icon: Icon(pipeline.isRunning ? Icons.hourglass_empty : Icons.play_arrow, size: 16),
                    label: Text(pipeline.isRunning ? 'Running...' : 'Run'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Visual step flow: Provider 1 → Provider 2 → Provider 3
  Widget _buildStepFlow(Pipeline pipeline, ColorScheme colorScheme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: pipeline.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = pipeline.isRunning && index == pipeline.currentStepIndex;
        final isComplete = pipeline.isRunning && index < pipeline.currentStepIndex;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primaryContainer
                    : isComplete
                        ? colorScheme.tertiaryContainer
                        : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: isActive ? Border.all(color: colorScheme.primary, width: 2) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(step.provider.category.emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    step.provider.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isComplete) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check_circle, size: 12, color: colorScheme.tertiary),
                  ],
                ],
              ),
            ),
            if (index < pipeline.steps.length - 1)
              Icon(Icons.arrow_forward, size: 14, color: colorScheme.onSurfaceVariant),
          ],
        );
      }).toList(),
    );
  }

  void _showPipelineDetails(Pipeline pipeline) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          children: [
            Text(pipeline.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(pipeline.description),
            const SizedBox(height: 24),
            Text('Steps', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...pipeline.steps.asMap().entries.map((entry) => ListTile(
              leading: CircleAvatar(
                child: Text('${entry.key + 1}'),
              ),
              title: Text(entry.value.provider.name),
              subtitle: Text(
                entry.value.promptTemplate,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _runPipeline(Pipeline pipeline) {
    setState(() {
      _runningPipeline = pipeline.copyWith(isRunning: true, currentStepIndex: 0);
      final idx = _pipelines.indexWhere((p) => p.id == pipeline.id);
      if (idx >= 0) _pipelines[idx] = _runningPipeline!;
    });

    // Show input dialog for initial prompt
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Run: ${pipeline.name}'),
        content: TextField(
          controller: _inputController,
          decoration: const InputDecoration(
            labelText: 'Input',
            hintText: 'Enter the initial input for the pipeline...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executePipelineSteps(pipeline);
            },
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }

  Future<void> _executePipelineSteps(Pipeline pipeline) async {
    var currentOutput = _inputController.text;

    for (int i = 0; i < pipeline.steps.length; i++) {
      final step = pipeline.steps[i];
      setState(() {
        final idx = _pipelines.indexWhere((p) => p.id == pipeline.id);
        if (idx >= 0) _pipelines[idx] = pipeline.copyWith(currentStepIndex: i + 1);
      });

      // Build prompt with previous output
      final prompt = step.buildPrompt(previousOutput: currentOutput);
      _stepResults[step.id] = prompt;

      // Simulate step execution (in production, open WebView and inject prompt)
      await Future.delayed(const Duration(seconds: 2));

      // Mock output for demo
      currentOutput = '[Step ${i + 1} output from ${step.provider.name}]';
    }

    setState(() {
      final idx = _pipelines.indexWhere((p) => p.id == pipeline.id);
      if (idx >= 0) {
        _pipelines[idx] = pipeline.copyWith(isRunning: false, currentStepIndex: pipeline.steps.length);
      }
    });
  }

  void _showCreatePipelineDialog() {
    // Pipeline creation UI - simplified for brevity
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Pipeline'),
        content: const Text('Select AI providers to chain together. Each step uses the output of the previous step as input.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Create')),
        ],
      ),
    );
  }
}
