import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/mesh_network_service.dart';
import 'services/chat_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isSetup = prefs.getBool('onboarding_complete') ?? false;
  final String? username = prefs.getString('username');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeshNetworkService()),
        ChangeNotifierProxyProvider<MeshNetworkService, ChatProvider>(
          create: (context) => ChatProvider(Provider.of<MeshNetworkService>(context, listen: false)),
          update: (context, network, previous) => previous ?? ChatProvider(network),
        ),
      ],
      child: BlueChatApp(isSetup: isSetup, initialUsername: username),
    ),
  );
}

class BlueChatApp extends StatefulWidget {
  final bool isSetup;
  final String? initialUsername;
  const BlueChatApp({super.key, required this.isSetup, this.initialUsername});

  @override
  State<BlueChatApp> createState() => _BlueChatAppState();
}

class _BlueChatAppState extends State<BlueChatApp> {
  @override
  void initState() {
    super.initState();
    if (widget.isSetup && widget.initialUsername != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MeshNetworkService>(context, listen: false).init(widget.initialUsername!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: widget.isSetup ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
