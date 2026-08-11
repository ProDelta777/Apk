import '../models/course.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';

class CourseData {
  static final List<Course> courses = [
    Course(
      id: 'python',
      title: 'Python',
      description: 'Learn Python programming from scratch.',
      icon: 'lucide_python', // Placeholder for actual icon mapping
      levels: [
        CourseLevel(
          title: 'Beginner',
          lessons: [
            Lesson(
              id: 'py_01',
              title: 'Introduction',
              explanation: 'Python is a high-level, interpreted programming language known for its simplicity and readability.',
              concept: 'Python is great for beginners.',
              syntax: 'print("Hello World")',
              codeExample: 'print("Hello, PRECODE!")',
              expectedOutput: 'Hello, PRECODE!',
              keyPoints: 'Simple syntax, readable, versatile.',
              language: 'python',
            ),
            Lesson(
              id: 'py_02',
              title: 'Variables',
              explanation: 'Variables are used to store data values.',
              concept: 'Think of variables as containers for storing data values.',
              codeExample: 'name = "PRECODE"\nprint(name)',
              expectedOutput: 'PRECODE',
              commonMistakes: 'Using reserved keywords as variable names.',
              language: 'python',
            ),
          ],
          quizzes: [
            QuizQuestion(
              id: 'py_q_01',
              question: 'Which function is used to output text to the console in Python?',
              type: 'multiple_choice',
              options: ['echo()', 'print()', 'console.log()', 'output()'],
              correctAnswer: 'print()',
              explanation: 'The print() function is the standard way to display output in Python.',
            ),
          ],
        ),
        CourseLevel(
          title: 'Intermediate',
          lessons: [
             Lesson(
              id: 'py_03',
              title: 'Loops',
              explanation: 'Loops are used to execute a block of code repeatedly.',
              concept: 'For loops iterate over a sequence (like a list, tuple, dictionary, set, or string).',
              codeExample: 'for i in range(3):\n    print(i)',
              expectedOutput: '0\n1\n2',
              language: 'python',
            ),
          ],
          quizzes: []
        )
      ],
    ),
    Course(
      id: 'html',
      title: 'HTML',
      description: 'The standard markup language for creating Web pages.',
      icon: 'lucide_html5',
      levels: [
        CourseLevel(
          title: 'Beginner',
          lessons: [
            Lesson(
              id: 'html_01',
              title: 'Introduction to HTML',
              explanation: 'HTML stands for Hyper Text Markup Language.',
              codeExample: '<!DOCTYPE html>\n<html>\n<body>\n<h1>Hello</h1>\n</body>\n</html>',
              expectedOutput: 'A webpage showing "Hello" as a heading.',
              language: 'html',
            ),
          ],
          quizzes: []
        )
      ],
    ),
  ];

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
    QuizQuestion(
      id: 'dc_03',
      question: 'What is the correct extension for a Python file?',
      type: 'multiple_choice',
      options: ['.py', '.python', '.pt', '.px'],
      correctAnswer: '.py',
      explanation: 'Python files are saved with the .py extension.',
    ),
  ];
}
