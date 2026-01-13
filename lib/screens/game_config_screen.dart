import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/game_mode.dart';
import '../providers/custom_categories_notifier.dart';
import '../providers/game_config_notifier.dart';
import '../providers/game_logic_provider.dart';
import '../providers/player_notifier.dart';
import '../repositories/word_repository.dart';

class GameConfigScreen extends ConsumerWidget {
  const GameConfigScreen({super.key});

  void _showCategoryInfo(
    BuildContext context,
    WidgetRef ref,
    String categoryName, {
    bool isCustom = false,
  }) {
    final wordPack = isCustom
        ? ref.read(customCategoriesProvider).firstWhere(
              (pack) => pack.categoryName == categoryName,
            )
        : WordRepository.wordPacks.firstWhere(
              (pack) => pack.categoryName == categoryName,
            );

    final allWords = <String>{
      for (final pair in wordPack.pairs) ...[pair.civilian, pair.imposter],
    };
    final wordsList = allWords.toList()..sort();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(categoryName),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: wordsList.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '• ${wordsList[index]}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (isCustom)
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(customCategoriesProvider.notifier)
                    .removeCategory(categoryName);
                Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.delete),
              label: const Text('DELETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddCustomCategoryDialog(
        onAdd: (categoryName, words) {
          ref
              .read(customCategoriesProvider.notifier)
              .addCategory(categoryName, words);
        },
      ),
    );
  }

  void _startGame(BuildContext context, WidgetRef ref) async {
    final config = ref.read(gameConfigProvider);

    if (config.selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final playerCount = ref.read(playerListProvider).length;
    if (config.imposterCount >= playerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imposter count must be less than total players ($playerCount)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(gameLogicProvider.notifier).initializeGame();

    final gameState = ref.read(gameLogicProvider);
    gameState.when(
      data: (_) => context.go('/reveal'),
      loading: () {},
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);
    final playerCount = ref.watch(playerListProvider).length;
    final customCategories = ref.watch(customCategoriesProvider);
    final theme = Theme.of(context);

    final maxImposterCount = playerCount > 1 ? playerCount - 1 : 1;
    final allCategories =
        WordRepository.getAllCategories(customPacks: customCategories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GAME CONFIG'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SELECT CATEGORIES',
                        style: theme.textTheme.headlineSmall,
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showAddCustomCategoryDialog(context, ref),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('ADD'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose one or more word categories',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: allCategories.map((category) {
                      final isSelected =
                          config.selectedCategories.contains(category);
                      final isCustom = customCategories
                          .any((pack) => pack.categoryName == category);

                      return SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilterChip(
                              label: Text(
                                isCustom ? '⭐ $category' : category,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              backgroundColor: const Color(0xFF262626),
                              selectedColor: const Color(0xFFFAFAFA),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFFAFAFA) : const Color(0xFF262626),
                              ),
                              onSelected: (_) {
                                ref
                                    .read(gameConfigProvider.notifier)
                                    .toggleCategory(category);
                              },
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showCategoryInfo(
                                    context,
                                    ref,
                                    category,
                                    isCustom: isCustom,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Icon(
                                    isCustom ? Icons.edit : Icons.info_outline,
                                    size: 20,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary
                                            .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),

                  Text(
                    'GAME MODE',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<GameMode>(
                    segments: GameMode.values.map((mode) {
                      return ButtonSegment(
                        value: mode,
                        label: Text(mode.displayName),
                        icon: Icon(
                          mode == GameMode.classic
                              ? Icons.visibility_off
                              : Icons.remove_red_eye,
                        ),
                      );
                    }).toList(),
                    selected: {config.gameMode},
                    onSelectionChanged: (Set<GameMode> newSelection) {
                      ref
                          .read(gameConfigProvider.notifier)
                          .setGameMode(newSelection.first);
                    },
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        config.gameMode.description,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),

                  Text(
                    'IMPOSTER COUNT',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: config.imposterCount.toDouble(),
                          min: 1,
                          max: maxImposterCount.toDouble(),
                          divisions: maxImposterCount - 1,
                          label: config.imposterCount.toString(),
                          onChanged: (value) {
                            ref
                                .read(gameConfigProvider.notifier)
                                .setImposterCount(value.toInt());
                          },
                        ),
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '${config.imposterCount}',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Total Players: $playerCount',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),
                  const Divider(),

                  Text(
                    'TIMER DURATION',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [3, 5, 7, 10].map((minutes) {
                      final isSelected =
                          config.timerDurationMinutes == minutes;
                      return ChoiceChip(
                        label: Text(
                          '$minutes min',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        backgroundColor: const Color(0xFF262626),
                        selectedColor: const Color(0xFFFAFAFA),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFFAFAFA) : const Color(0xFF262626),
                        ),
                        onSelected: (_) {
                          ref
                              .read(gameConfigProvider.notifier)
                              .setTimerDuration(minutes);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startGame(context, ref),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('START GAME'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCustomCategoryDialog extends StatefulWidget {
  final void Function(String, List<String>) onAdd;

  const _AddCustomCategoryDialog({required this.onAdd});

  @override
  State<_AddCustomCategoryDialog> createState() =>
      _AddCustomCategoryDialogState();
}

class _AddCustomCategoryDialogState extends State<_AddCustomCategoryDialog> {
  late List<TextEditingController> wordControllers;
  late TextEditingController categoryNameController;

  @override
  void initState() {
    super.initState();
    categoryNameController = TextEditingController();
    wordControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    for (final controller in wordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMoreWords() {
    setState(() {
      wordControllers.add(TextEditingController());
    });
  }

  void _removeWord(int index) {
    if (wordControllers.length > 6) {
      setState(() {
        wordControllers[index].dispose();
        wordControllers.removeAt(index);
      });
    }
  }

  void _submit(BuildContext context) {
    final categoryName = categoryNameController.text.trim();
    final words = wordControllers
        .map((c) => c.text.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (words.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please enter at least 6 words (${words.length}/6)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    widget.onAdd(categoryName, words);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ADD CUSTOM CATEGORY'),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Superheroes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter at least 6 words:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                wordControllers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: wordControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Word ${index + 1}',
                      border: const OutlineInputBorder(),
                      suffixIcon: wordControllers.length > 6
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeWord(index),
                            )
                          : null,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ),
              if (wordControllers.length == 6)
                TextButton.icon(
                  onPressed: _addMoreWords,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD MORE WORDS'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () => _submit(context),
          child: const Text('ADD CATEGORY'),
        ),
      ],
    );
  }
}
