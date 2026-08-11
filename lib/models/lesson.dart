class Lesson {
  final String id;
  final String title;
  final String explanation;
  final String? concept;
  final String? syntax;
  final String? codeExample;
  final String? expectedOutput;
  final String? commonMistakes;
  final String? keyPoints;
  final String? miniPractice;
  final String? language;

  Lesson({
    required this.id,
    required this.title,
    required this.explanation,
    this.concept,
    this.syntax,
    this.codeExample,
    this.expectedOutput,
    this.commonMistakes,
    this.keyPoints,
    this.miniPractice,
    this.language,
  });
}
