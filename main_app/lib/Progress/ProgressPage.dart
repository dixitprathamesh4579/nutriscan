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

  int safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return double.tryParse(value.toString())?.round() ?? 0;
  }

  double safeDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Your Weekly Summary"),
                  const SizedBox(height: 12),

                  /// SUMMARY
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: "Weekly Calories",
                          value: weeklyData.fold<int>(
                            0,
                            (sum, row) =>
                                sum + safeInt(row['total_calories']),
                          ).toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: "Avg Daily Calories",
                          value: (weeklyData.isEmpty
                                  ? 0
                                  : (weeklyData.fold<int>(
                                              0,
                                              (sum, row) =>
                                                  sum +
                                                  safeInt(
                                                      row['total_calories']),
                                            ) /
                                            weeklyData.length)
                                        .round())
                              .toString(),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: "Total Protein",
                          value: weeklyData.fold<int>(
                                    0,
                                    (sum, row) =>
                                        sum + safeInt(row['total_protein']),
                                  ).toString() +
                              " g",
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: "Total Sugar",
                          value: weeklyData.fold<int>(
                                    0,
                                    (sum, row) =>
                                        sum + safeInt(row['total_sugar']),
                                  ).toString() +
                              " g",
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _header("Weekly Calories"),
                  ChartCard(
                    child: weeklyData.isEmpty
                        ? const Center(child: Text("No data"))
                        : WeeklyCaloriesChart(data: weeklyData),
                  ),

                  const SizedBox(height: 24),

                  _header("Weekly Protein Trend"),
                  ChartCard(
                    child: weeklyData.isEmpty
                        ? const Center(child: Text("No data"))
                        : _proteinTrendChart(),
                  ),

                  const SizedBox(height: 24),

                  _header("Monthly Sugar Consumption"),
                  ChartCard(
                    child: monthlyData.isEmpty
                        ? const Center(child: Text("No data"))
                        : MonthlySugarChart(data: monthlyData),
                  ),

                  const SizedBox(height: 24),

                  /// ✅ CHANGED HERE
                  _header("Weekly Nutrient Ratio"),
                  const SizedBox(height: 12),
                  ChartCard(
                    child: weeklyData.isEmpty
                        ? const Center(child: Text("No data"))
                        : WeeklyNutrientPie(weeklyData),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _proteinTrendChart() {
    double avg = weeklyData.isEmpty
        ? 0
        : weeklyData
                .map((e) => safeDouble(e['total_protein']))
                .reduce((a, b) => a + b) /
            weeklyData.length;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (t) => Colors.black87,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.x.toInt();
                final date = weeklyData[index]['date'].substring(5);
                return LineTooltipItem(
                  "$date\n${spot.y.toInt()} g",
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              weeklyData.length,
              (i) => FlSpot(
                i.toDouble(),
                safeDouble(weeklyData[i]['total_protein']),
              ),
            ),
            isCurved: true,
            color: Colors.green,
            barWidth: 4,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: List.generate(
              weeklyData.length,
              (i) => FlSpot(i.toDouble(), avg),
            ),
            color: Colors.grey,
            barWidth: 2,
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

/// WEEKLY PIE (NEW)
class WeeklyNutrientPie extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const WeeklyNutrientPie(this.data, {super.key});

  double safeDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    double carbs = 0, fat = 0, protein = 0;

    for (var row in data) {
      carbs += safeDouble(row['total_carbs']);
      fat += safeDouble(row['total_fat']);
      protein += safeDouble(row['total_protein']);
    }

    final total = carbs + fat + protein;

    return total == 0
    ? const Center(child: Text("No data"))
    : Column(
        children: [
          /// PIE CHART
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                sections: [
                  PieChartSectionData(
                    value: carbs,
                    color: Colors.orange,
                    title:
                        "${(carbs / total * 100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: fat,
                    color: Colors.red,
                    title:
                        "${(fat / total * 100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: protein,
                    color: Colors.green,
                    title:
                        "${(protein / total * 100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// LEGEND (THIS FIXES YOUR ISSUE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem("Carbs", Colors.orange),
              _legendItem("Fat", Colors.red),
              _legendItem("Protein", Colors.green),
            ],
          ),
        ],
      
          );
  }
}

/// SUMMARY + CHART CLASSES (UNCHANGED BELOW)
class SummaryCard extends StatelessWidget {
  final String title, value;
  final Color color;

  const SummaryCard(
      {super.key,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 18)),
        ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: child,
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
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[group.x]['date'].substring(5);
              return BarTooltipItem(
                "$date\n${rod.toY.toInt()} g",
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (data[i]['total_sugar'] ?? 0).toDouble(),
                width: 16,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.orange],
                ),
              ),
            ],
          ),
        ),
      ),
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (t) => Colors.black87,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.x.toInt();
                final date = data[index]['date'].substring(5);
                return LineTooltipItem(
                  "$date\n${spot.y.toInt()} kcal",
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: true),
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
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
Widget _legendItem(String text, Color color) {
  return Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(text),
    ],
  );
}