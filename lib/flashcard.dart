import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alphaapplication/Flashcardprovider.dart';

class Flashcard extends StatelessWidget {
  const Flashcard({super.key});

  void showAddCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CardFormDialog(
        title: 'Add Flashcard',
        buttonText: 'Save',
        onSave: (question, answer) {
          context.read<FlashcardProvider>().addCard(question, answer);
        },
      ),
    );
  }

  void showEditCardDialog(BuildContext context) {
    final provider = context.read<FlashcardProvider>();

    if (provider.cards.isEmpty) return;

    final index = provider.currentIndex;
    final card = provider.cards[index];

    showDialog(
      context: context,
      builder: (_) => CardFormDialog(
        key: UniqueKey(),
        title: 'Edit Flashcard',
        buttonText: 'Update',
        initialQuestion: card['question'] ?? '',
        initialAnswer: card['answer'] ?? '',
        onSave: (question, answer) {
          provider.editCard(index, question, answer);
        },
      ),
    );
  }

  Future<void> confirmDeleteCard(BuildContext context) async {
    final provider = context.read<FlashcardProvider>();

    if (provider.cards.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Flashcard?'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      provider.deleteCard(provider.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final hasCards = provider.cards.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F7),
      appBar: AppBar(
        title: const Text(
          'FlashLearn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text(
              'Learn Something New!',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Card ${hasCards ? provider.currentIndex + 1 : 0} '
              'of ${provider.cards.length}',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: hasCards
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              provider.showAnswer
                                  ? Icons.lightbulb
                                  : Icons.help_outline,
                              size: 50,
                              color: Colors.teal,
                            ),
                            const SizedBox(height: 25),
                            Text(
                              provider.showAnswer ? 'ANSWER' : 'QUESTION',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              provider.showAnswer
                                  ? provider.cards[provider
                                        .currentIndex]['answer']!
                                  : provider.cards[provider
                                        .currentIndex]['question']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books_outlined,
                              size: 55,
                              color: Colors.teal,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No Flashcards Yet',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap Add Flashcard to create your first card.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SHOW ANSWER BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: hasCards
                    ? () => context.read<FlashcardProvider>().toggleAnswer()
                    : null,
                icon: const Icon(Icons.visibility),
                label: Text(
                  provider.showAnswer ? 'Show Question' : 'Show Answer',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // PREVIOUS AND NEXT
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasCards && provider.currentIndex > 0
                        ? () => context.read<FlashcardProvider>().previousCard()
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        hasCards &&
                            provider.currentIndex < provider.cards.length - 1
                        ? () => context.read<FlashcardProvider>().nextCard()
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ADD BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => showAddCardDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Flashcard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasCards
                        ? () => showEditCardDialog(context)
                        : null,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasCards
                        ? () => confirmDeleteCard(context)
                        : null,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class CardFormDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final String initialQuestion;
  final String initialAnswer;
  final void Function(String question, String answer) onSave;

  const CardFormDialog({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onSave,
    this.initialQuestion = '',
    this.initialAnswer = '',
  });

  @override
  State<CardFormDialog> createState() => _CardFormDialogState();
}

class _CardFormDialogState extends State<CardFormDialog> {
  late final TextEditingController questionController;
  late final TextEditingController answerController;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.initialQuestion);
    answerController = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  void saveCard() {
    final question = questionController.text.trim();
    final answer = answerController.text.trim();

    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both question and answer')),
      );
      return;
    }

    widget.onSave(question, answer);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.help_outline),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lightbulb_outline),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: saveCard, child: Text(widget.buttonText)),
      ],
    );
  }
}
