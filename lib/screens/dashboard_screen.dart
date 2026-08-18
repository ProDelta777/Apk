import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'rate_calculator_screen.dart';
import 'itemized_bill_screen.dart';
import 'cash_counter_screen.dart';
import 'history_screen.dart';
import 'profit_calculator_screen.dart';
import 'khata_screen.dart';
import 'discount_calculator_screen.dart';
import '../widgets/math_mesh_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('QuantaCalc Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: MathMeshBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.blueAccent.shade700, Colors.purpleAccent.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'QuantaCalc',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 15, offset: Offset(3, 6)),
                              Shadow(color: Colors.blueAccent, blurRadius: 30, offset: Offset(0, 0)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              const Text(
                'Your all-in-one smart shop assistant.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Discount Calc',
                      Icons.local_offer,
                      Colors.pinkAccent,
                      const DiscountCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Smart Bill',
                      Icons.calculate,
                      Colors.blue,
                      const CalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Itemized Bill',
                      Icons.receipt_long,
                      Colors.purple,
                      const ItemizedBillScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Bhaav (Rate)',
                      Icons.scale,
                      Colors.orange,
                      const RateCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Cash Tally',
                      Icons.account_balance_wallet,
                      Colors.green,
                      const CashCounterScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Udhar Khata',
                      Icons.menu_book,
                      Colors.redAccent,
                      const KhataScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Profit Calc',
                      Icons.trending_up,
                      Colors.teal,
                      const ProfitCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'History',
                      Icons.history,
                      Colors.blueGrey,
                      const HistoryScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget targetScreen,
  ) {
    return Card(
      elevation: 4,
      shadowColor: color.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withAlpha(25),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
