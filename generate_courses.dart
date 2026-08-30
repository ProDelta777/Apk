import 'dart:io';

void main() {
  final file = File('lib/data/course_data.dart');

  final buffer = StringBuffer();
  buffer.writeln("import '../models/course.dart';");
  buffer.writeln("import '../models/lesson.dart';");
  buffer.writeln("import '../models/quiz_question.dart';");
  buffer.writeln("");
  buffer.writeln("class CourseData {");
  buffer.writeln("  static final List<Course> courses = [");

  final languages = ['C', 'C++', 'Java', 'Python', 'JavaScript', 'HTML', 'CSS', 'SQL', 'Git', 'DSA'];
  final descriptions = [
    'System programming language.',
    'Object-oriented C.',
    'Write once, run anywhere.',
    'Readability and simplicity.',
    'Web interactivity.',
    'Web markup.',
    'Web styling.',
    'Database querying.',
    'Version control.',
    'Data Structures & Algorithms.'
  ];
  final identifiers = ['c', 'cpp', 'java', 'python', 'javascript', 'html', 'css', 'sql', 'git', 'dsa'];

  for (int l = 0; l < languages.length; l++) {
    buffer.writeln("    Course(");
    buffer.writeln("      id: '${identifiers[l]}',");
    buffer.writeln("      title: '${languages[l]}',");
    buffer.writeln("      description: '${descriptions[l]}',");
    buffer.writeln("      icon: 'lucide_code',");
    buffer.writeln("      levels: [");

    // Create 100 levels (Level 1 to Level 100)
    for (int level = 1; level <= 100; level++) {
      buffer.writeln("        CourseLevel(");
      buffer.writeln("          title: 'Level $level',");
      buffer.writeln("          lessons: [");

      // Add 1 lesson per level to keep file size reasonable while still having 100 levels
      buffer.writeln("            Lesson(");
      buffer.writeln("              id: '${identifiers[l]}_lvl${level}_1',");
      buffer.writeln("              title: '${languages[l]} Concept $level',");
      buffer.writeln("              explanation: 'This is the explanation for ${languages[l]} Level $level.',");
      buffer.writeln("              codeExample: 'print(\"Hello from ${languages[l]} Level $level!\")',");
      buffer.writeln("              expectedOutput: 'Hello from ${languages[l]} Level $level!',");
      buffer.writeln("              language: '${identifiers[l]}',");
      buffer.writeln("            ),");

      buffer.writeln("          ],");
      buffer.writeln("          quizzes: [],");
      buffer.writeln("        ),");
    }

    buffer.writeln("      ],");
    buffer.writeln("    ),");
  }

  buffer.writeln("  ];");

  buffer.writeln("""
  static final List<QuizQuestion> dailyChallenges = [
    QuizQuestion(
      id: 'dc_01',
      question: 'What will this Python code output?',
      type: 'output_prediction',
      codeSnippet: 'print(2 ** 3)',
      options: ['6', '8', '9', 'Error'],
      correctAnswer: '8',
      explanation: 'The ** operator is used for exponentiation. 2 to the power of 3 is 8.',
    ),
    QuizQuestion(
      id: 'dc_02',
      question: 'Which HTML tag creates a hyperlink?',
      type: 'multiple_choice',
      options: ['<link>', '<a>', '<hyper>', '<href>'],
      correctAnswer: '<a>',
      explanation: 'The <a> (anchor) tag defines a hyperlink.',
    ),
  ];
}
""");

  file.writeAsStringSync(buffer.toString());
  print('Generated lib/data/course_data.dart with 10 languages and 100 levels each.');
}
