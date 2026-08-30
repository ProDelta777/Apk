class QuizQuestion {
  final String id;
  final String question;
  final String type; // e.g., 'multiple_choice', 'true_false', 'output_prediction', 'code'
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? codeSnippet;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.codeSnippet,
  });
}
