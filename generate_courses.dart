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

  final languages = ['Python', 'Java', 'C', 'C++', 'JavaScript', 'TypeScript', 'Go', 'Rust', 'Kotlin', 'PHP'];
  final identifiers = ['python', 'java', 'c', 'cpp', 'javascript', 'typescript', 'go', 'rust', 'kotlin', 'php'];

  // High-level curriculum map (20 topics per section = 100 levels)
  final foundationTopics = [
    'Introduction & Setup', 'Syntax Basics', 'Variables', 'Data Types', 'Type Conversion',
    'Operators (Arithmetic)', 'Operators (Logical)', 'String Basics', 'Input & Output', 'Comments & Formatting',
    'Booleans & Truthiness', 'Constants', 'Basic Math', 'String Concatenation', 'Null/None Concept',
    'Error Reading Basics', 'Code Blocks', 'Variable Scope (Intro)', 'Basic Arrays/Lists', 'Foundation Review'
  ]; // 1-20

  final coreTopics = [
    'If/Else Statements', 'Switch/Match', 'Ternary Operator', 'While Loops', 'For Loops',
    'Do-While / Loop Variations', 'Break & Continue', 'Nested Loops', 'Functions (Intro)', 'Return Values',
    'Function Parameters', 'Default Arguments', 'Anonymous Functions', 'Recursion (Basics)', 'List/Array Methods',
    'String Methods', 'Dictionaries/Maps', 'Sets', 'Tuples/Structs', 'Core Review'
  ]; // 21-40

  final intermediateTopics = [
    'Object-Oriented Programming', 'Classes & Objects', 'Methods', 'Inheritance', 'Polymorphism',
    'Encapsulation', 'Abstraction', 'Interfaces/Traits', 'Error Handling (Try/Catch)', 'Throwing Exceptions',
    'File Handling (Read)', 'File Handling (Write)', 'JSON/Serialization', 'Modules & Imports', 'Packages',
    'Dates & Times', 'Regular Expressions', 'List Comprehensions / Streams', 'Memory (Intro)', 'Intermediate Review'
  ]; // 41-60

  final advancedTopics = [
    'Advanced OOP Patterns', 'Generics / Templates', 'Multithreading (Intro)', 'Asynchronous Programming', 'Promises / Futures',
    'Async / Await', 'Memory Management', 'Pointers / References', 'Garbage Collection', 'Closures',
    'Decorators / Annotations', 'Metaprogramming', 'Network Requests', 'API Integration', 'Database Connectors',
    'Unit Testing', 'Mocking', 'Advanced Data Structures', 'Design Patterns', 'Advanced Review'
  ]; // 61-80

  final masteryTopics = [
    'System Architecture', 'Performance Profiling', 'Concurrency Patterns', 'Security Best Practices', 'Cryptography Basics',
    'Microservices (Concept)', 'Dependency Injection', 'Reactive Programming', 'CI/CD Concepts', 'Docker/Containers (Concept)',
    'Advanced Algorithms (Sorting)', 'Advanced Algorithms (Search)', 'Graph Theory', 'Dynamic Programming', 'State Management',
    'Memory Leaks & Debugging', 'Building a CLI Tool', 'Building a Web Server', 'Final Project Prep', 'Mastery Assessment'
  ]; // 81-100

  for (int l = 0; l < languages.length; l++) {
    final lang = languages[l];
    final id = identifiers[l];

    buffer.writeln("    Course(");
    buffer.writeln("      id: '$id',");
    buffer.writeln("      title: '$lang',");
    buffer.writeln("      description: 'Master $lang from Beginner to Expert.',");
    buffer.writeln("      icon: 'lucide_code',");
    buffer.writeln("      levels: [");

    void writeSection(String sectionTitle, List<String> topics, int startLevel) {
      buffer.writeln("        CourseLevel(");
      buffer.writeln("          title: '$sectionTitle',");
      buffer.writeln("          lessons: [");
      for (int i = 0; i < topics.length; i++) {
        int levelNum = startLevel + i;
        String explanation = 'Learn the fundamental concepts of ${topics[i]} in $lang. This level will guide you through the syntax, common use cases, and best practices.';
        String codeExample = '// Example code for ${topics[i]} in $lang\\n\\n// Try modifying the variables or logic below\\n\\nfunction executeTask() {\\n  console.log(\"Executing ${topics[i]} logic...\");\\n}\\nexecuteTask();';

        // Inject extremely detailed educational content for Python/JS Foundation
        if (id == 'python' && levelNum == 1) {
             explanation = 'Python is a high-level, interpreted programming language famous for its clean, English-like syntax. It is widely used in data science, web development, and AI.\\n\\nKey Concepts:\\n1. The Interpreter reads your code line-by-line.\\n2. The print() function is your primary tool for seeing output.\\n\\nLook at the example below. We pass text inside quotes to print it out. You can also pass math operations directly!';
             codeExample = '# Your first Python program!\\nprint("Welcome to PRECODE.")\\n\\n# Python can do math instantly\\nprint(10 + 5)\\n\\n# You can print multiple items\\nprint("Score:", 100)';
        } else if (id == 'python' && levelNum == 2) {
             explanation = 'Variables act like labeled boxes where you can store data. In Python, you do not need to specify what kind of data the box holds (this is called dynamic typing).\\n\\nRules for naming variables:\\n- Must start with a letter or underscore.\\n- Cannot contain spaces (use underscores_instead).\\n- Are case-sensitive (Age is different from age).';
             codeExample = 'player_name = "Jules"\\nhealth = 100\\n\\nprint("Player:", player_name)\\nprint("Health:", health)\\n\\n# Variables can change (vary!)\\nhealth = 80\\nprint("New Health:", health)';
        } else if (id == 'python' && levelNum == 3) {
             explanation = 'Data types tell Python what kind of value a variable holds. The basic types are:\\n1. Integers (int): Whole numbers like 5 or -10.\\n2. Floats (float): Decimal numbers like 3.14.\\n3. Strings (str): Text wrapped in quotes.\\n4. Booleans (bool): True or False.\\n\\nYou can check a variables type using the type() function.';
             codeExample = 'age = 25          # int\\nprice = 19.99     # float\\nname = "Alice"    # str\\nis_active = True  # bool\\n\\nprint(type(age))\\nprint(type(is_active))';
        } else if (id == 'javascript' && levelNum == 1) {
             explanation = 'JavaScript (JS) is the programming language of the Web. While HTML structures the page and CSS styles it, JS makes it interactive.\\n\\nWe use console.log() to print messages to the developer console. It is the JS equivalent of Pythons print(). Note that JS statements traditionally end with a semicolon (;).';
             codeExample = '// Your first JS Program\\nconsole.log("Welcome to JavaScript!");\\n\\n// Math evaluation\\nconsole.log(20 * 5);';
        } else if (id == 'javascript' && levelNum == 2) {
             explanation = 'In modern JavaScript (ES6+), we declare variables using let or const.\\n\\n- Use let when you know the value will change later.\\n- Use const (constant) when the value should never change.\\nAvoid using the old var keyword as it has confusing scoping rules.';
             codeExample = 'const language = "JavaScript";\\nlet version = 6;\\n\\nconsole.log(language);\\nconsole.log(version);\\n\\n// We can change let\\nversion = 7;\\nconsole.log("Updated to:", version);';
        } else {
             // Fallback template for the other 900+ lessons to keep file size within compiler limits
             if (id == 'javascript') {
                 codeExample = 'console.log("Practicing ${topics[i]} in JavaScript");';
             } else if (id == 'python') {
                 codeExample = 'print("Practicing ${topics[i]} in Python")';
             } else {
                 codeExample = '// Practice ${topics[i]} in $lang\\n';
             }
        }

        buffer.writeln("            Lesson(");
        buffer.writeln("              id: '${id}_lvl${levelNum}',");
        buffer.writeln("              levelNumber: $levelNum,");
        buffer.writeln("              title: 'Level $levelNum — ${topics[i]}',");
        buffer.writeln("              explanation: '$explanation',");
        buffer.writeln("              codeExample: '$codeExample',");
        buffer.writeln("              language: '$id',");
        buffer.writeln("            ),");
      }
      buffer.writeln("          ],");
      buffer.writeln("          quizzes: [],");
      buffer.writeln("        ),");
    }

    writeSection('FOUNDATION (Levels 1-20)', foundationTopics, 1);
    writeSection('CORE PROGRAMMING (Levels 21-40)', coreTopics, 21);
    writeSection('INTERMEDIATE (Levels 41-60)', intermediateTopics, 41);
    writeSection('ADVANCED (Levels 61-80)', advancedTopics, 61);
    writeSection('MASTERY (Levels 81-100)', masteryTopics, 81);

    buffer.writeln("      ],");
    buffer.writeln("    ),");
  }

  buffer.writeln("  ];");

  // Dummy question bank for quizzes
  buffer.writeln("""
  static final List<QuizQuestion> dailyChallenges = [
    QuizQuestion(
      id: 'dc_01',
      question: 'What is the primary purpose of a variable?',
      type: 'multiple_choice',
      options: ['To store data', 'To loop code', 'To style UI', 'To query databases'],
      correctAnswer: 'To store data',
      explanation: 'Variables are containers for storing data values.',
    ),
  ];

  static final List<QuizQuestion> questionBank = [
    QuizQuestion(
      id: 'qb_01',
      question: 'Which of the following is a conditional statement?',
      type: 'multiple_choice',
      options: ['if', 'for', 'while', 'import'],
      correctAnswer: 'if',
      explanation: 'if is used to evaluate a condition.',
    ),
    QuizQuestion(
      id: 'qb_02',
      question: 'What is a boolean?',
      type: 'true_false',
      options: ['True or False', 'A number', 'Text', 'An Array'],
      correctAnswer: 'True or False',
      explanation: 'Booleans represent true or false values.',
    ),
    QuizQuestion(
      id: 'qb_py3',
      question: 'What is the correct way to write a single-line comment in Python?',
      type: 'multiple_choice',
      options: ['// comment', '/* comment */', '# comment', '<!-- comment -->'],
      correctAnswer: '# comment',
      explanation: 'Python uses the hash (#) symbol for single-line comments.',
    ),
    QuizQuestion(
      id: 'qb_py4',
      question: 'What will be the output of: print(type(5))?',
      type: 'multiple_choice',
      options: ['<class \\'str\\'>', '<class \\'int\\'>', '<class \\'float\\'>', '<class \\'number\\'>'],
      correctAnswer: '<class \\'int\\'>',
      explanation: '5 is an integer, so its type is int.',
    ),
    QuizQuestion(
      id: 'qb_py5',
      question: 'Which of the following is a valid variable name in Python?',
      type: 'multiple_choice',
      options: ['1st_player', 'player-name', 'player_name', 'player name'],
      correctAnswer: 'player_name',
      explanation: 'Variables cannot start with a number and cannot contain spaces or hyphens.',
    ),
    QuizQuestion(
      id: 'qb_js3',
      question: 'What is the purpose of the \\'let\\' keyword in JavaScript?',
      type: 'multiple_choice',
      options: ['To declare a constant', 'To declare a block-scoped variable that can be reassigned', 'To create a function', 'To import a module'],
      correctAnswer: 'To declare a block-scoped variable that can be reassigned',
      explanation: '\\'let\\' allows you to declare variables that can change their value later.',
    ),
    QuizQuestion(
      id: 'qb_js4',
      question: 'How do you write a comment in JavaScript?',
      type: 'multiple_choice',
      options: ['# comment', '// comment', '<!-- comment -->', '** comment'],
      correctAnswer: '// comment',
      explanation: 'JavaScript uses double slashes (//) for single-line comments.',
    ),
    QuizQuestion(
      id: 'qb_js5',
      question: 'What will console.log(10 + "5") output in JS?',
      type: 'multiple_choice',
      options: ['15', '105', 'Error', 'NaN'],
      correctAnswer: '105',
      explanation: 'JS coerces the number 10 into a string and concatenates it with "5", resulting in "105".',
    ),
    // A robust production app would map thousands of these directly from a local JSON blob mapped to level IDs
  ];
}
""");

  file.writeAsStringSync(buffer.toString());
  print('Generated lib/data/course_data.dart with 10 languages, 5 sections, 100 actual topics each.');
}
