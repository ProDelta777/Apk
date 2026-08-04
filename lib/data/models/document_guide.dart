class DocumentGuide {
  final String title;
  final String iconPath; // Use a built-in icon or custom icon mapping later
  final String purpose;
  final String eligibility;
  final List<String> requiredDocuments;
  final List<String> processSteps;
  final String estimatedTime;
  final String importantNotes;
  final String commonMistakes;
  final List<Map<String, String>> faq;

  const DocumentGuide({
    required this.title,
    required this.iconPath,
    required this.purpose,
    required this.eligibility,
    required this.requiredDocuments,
    required this.processSteps,
    required this.estimatedTime,
    required this.importantNotes,
    required this.commonMistakes,
    required this.faq,
  });
}
