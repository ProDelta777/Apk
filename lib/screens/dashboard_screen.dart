import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'rate_calculator_screen.dart';
import 'itemized_bill_screen.dart';
import 'cash_counter_screen.dart';

import 'profit_calculator_screen.dart';
import 'khata_screen.dart';
import 'discount_calculator_screen.dart';
import 'gst_calculator_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Quanta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Tools', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2DD4BF))),
                ],
              ),
              const SizedBox(height: 4),
              Text('Professional Business Utilities', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildDashboardCard(
                      context,
                      'GST Calc',
                      Icons.percent_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFF60A5FA),
                      const GstCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Discount Calc',
                      Icons.local_offer_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFFF43F5E),
                      const DiscountCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Smart Bill',
                      Icons.calculate_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFF3B82F6),
                      const CalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Itemized Bill',
                      Icons.receipt_long_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFFA855F7),
                      const ItemizedBillScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Bhaav (Rate)',
                      Icons.scale_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFFF59E0B),
                      const RateCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Cash Tally',
                      Icons.account_balance_wallet_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFF10B981),
                      const CashCounterScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Udhar Khata',
                      Icons.menu_book_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFFEF4444),
                      const KhataScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Profit Calc',
                      Icons.trending_up_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFF14B8A6),
                      const ProfitCalculatorScreen(),
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
    Color bgColor,
    Color iconColor,
    Widget targetScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(2, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
