import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'rate_calculator_screen.dart';
import 'itemized_bill_screen.dart';
import 'cash_counter_screen.dart';
import 'history_screen.dart';
import 'profit_calculator_screen.dart';
import 'khata_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('QuantaCalc Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to QuantaCalc',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
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
