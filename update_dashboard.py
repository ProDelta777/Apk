with open("lib/screens/dashboard_screen.dart", "r") as f:
    content = f.read()

# Add GST calculator to the tools grid as requested
import_statement = "import 'profit_calculator_screen.dart';\nimport 'khata_screen.dart';\nimport 'discount_calculator_screen.dart';\nimport 'gst_calculator_screen.dart';"
content = content.replace("import 'profit_calculator_screen.dart';\nimport 'khata_screen.dart';\nimport 'discount_calculator_screen.dart';", import_statement)

gst_card = """                    _buildDashboardCard(
                      context,
                      'GST Calc',
                      Icons.percent_outlined,
                      const Color(0xFF1E293B),
                      const Color(0xFF60A5FA),
                      const GstCalculatorScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      'Discount Calc',"""
content = content.replace("                    _buildDashboardCard(\n                      context,\n                      'Discount Calc',", gst_card)

with open("lib/screens/dashboard_screen.dart", "w") as f:
    f.write(content)
