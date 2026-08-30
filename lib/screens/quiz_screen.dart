import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/darcula.dart';

import '../models/quiz_question.dart';
import '../providers/progress_provider.dart';

class QuizScreen extends StatefulWidget {
  final QuizQuestion question;

  const QuizScreen({super.key, required this.question});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _selectedOption;
  bool _hasAnswered = false;
  bool _isCorrect = false;

  void _submitAnswer() {
    if (_selectedOption == null) return;

    setState(() {
      _hasAnswered = true;
      _isCorrect = _selectedOption == widget.question.correctAnswer;
    });

    if (_isCorrect) {
      context.read<ProgressProvider>().completeQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            if (widget.question.codeSnippet != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HighlightView(
                  widget.question.codeSnippet!,
                  language: 'python',
                  theme: darculaTheme,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ...widget.question.options.map((option) => _buildOption(option)).toList(),
            const SizedBox(height: 32),
            if (_hasAnswered) _buildExplanation(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _hasAnswered ? () => Navigator.pop(context) : (_selectedOption != null ? _submitAnswer : null),
            child: Text(_hasAnswered ? 'Continue' : 'Submit Answer'),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String option) {
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color backgroundColor = Colors.transparent;

    if (_hasAnswered) {
      if (option == widget.question.correctAnswer) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
      } else if (option == _selectedOption) {
        borderColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
      }
    } else if (option == _selectedOption) {
      borderColor = Theme.of(context).primaryColor;
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: _hasAnswered ? null : () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _hasAnswered && option == widget.question.correctAnswer
                  ? Icons.check_circle
                  : _hasAnswered && option == _selectedOption
                      ? Icons.cancel
                      : option == _selectedOption ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: borderColor,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(option, style: Theme.of(context).textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isCorrect ? Colors.green : Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isCorrect ? Icons.check_circle : Icons.info, color: _isCorrect ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Text(_isCorrect ? 'Correct! +20 XP' : 'Incorrect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _isCorrect ? Colors.green : Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.question.explanation, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
