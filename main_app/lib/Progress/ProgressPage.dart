import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> weeklyData = [];
  List<Map<String, dynamic>> monthlyData = [];
  late Future<void> loadFuture;

  @override
  void initState() {
    super.initState();
    loadFuture = loadProgressData();
  }

  Future<void> loadProgressData() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;

      final today = DateTime.now();
      final weekStart = today.subtract(const Duration(days: 6));
      final monthStart = DateTime(today.year, today.month, 1);

      String format(DateTime d) => d.toIso8601String().split("T").first;

      final weekly = await supabase
          .from('daily_nutrition')
          .select()
          .eq('profile_id', uid)
          .gte('date', format(weekStart))
          .order('date');

      final monthly = await supabase
          .from('daily_nutrition')
          .select()
          .eq('profile_id', uid)
          .gte('date', format(monthStart))
          .order('date');

      setState(() {
        weeklyData = List<Map<String, dynamic>>.from(weekly);
        monthlyData = List<Map<String, dynamic>>.from(monthly);
      });
    } catch (e) {
      debugPrint("Error loading progress data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: loadProgressData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Weekly Calories"),
                  ChartCard(
                    child: weeklyData.isEmpty
                        ? const Center(child: Text("No data"))
                        : WeeklyCaloriesChart(data: weeklyData),
                  ),

                  const SizedBox(height: 24),
                  _header("Monthly Sugar Consumption"),
                  ChartCard(
                    child: monthlyData.isEmpty
                        ? const Center(child: Text("No data"))
                        : MonthlySugarChart(data: monthlyData),
                  ),

                  const SizedBox(height: 24),
                  _header("Daily Nutrient Ratio"),
                  const SizedBox(height: 12),

                  ...weeklyData.map((entry) => NutrientPieCard(entry)).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


class ChartCard extends StatelessWidget {
  final Widget child;
  const ChartCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}



class WeeklyCaloriesChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const WeeklyCaloriesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(
                i.toDouble(),
                (data[i]['total_calories'] ?? 0).toDouble(),
              ),
            ),
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox();
                }
                final date = data[index]['date'].substring(5); // MM-DD
                return Text(date, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}


class MonthlySugarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const MonthlySugarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (data[i]['total_sugar'] ?? 0).toDouble(),
                width: 14,
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                final date = data[index]['date'].substring(5); // "MM-DD"
                return Text(date, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}



class NutrientPieCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const NutrientPieCard(this.row, {super.key});

  @override
  Widget build(BuildContext context) {
    final carbs = (row['total_carbs'] ?? 0).toDouble();
    final fat = (row['total_fat'] ?? 0).toDouble();
    final protein = (row['total_protein'] ?? 0).toDouble();
    final total = carbs + fat + protein;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row['date'] ?? "Unknown Date",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: total == 0
                ? const Center(child: Text("No nutrient data"))
                : PieChart(
                    PieChartData(
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                      sections: [
                        PieChartSectionData(
                          value: carbs,
                          color: Colors.orange,
                          title:
                              "Carbs ${(carbs / total * 100).toStringAsFixed(0)}%",
                          radius: 45,
                          titleStyle: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: fat,
                          color: Colors.red,
                          title:
                              "Fat ${(fat / total * 100).toStringAsFixed(0)}%",
                          radius: 45,
                          titleStyle: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: protein,
                          color: Colors.green,
                          title:
                              "Protein ${(protein / total * 100).toStringAsFixed(0)}%",
                          radius: 45,
                          titleStyle: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
