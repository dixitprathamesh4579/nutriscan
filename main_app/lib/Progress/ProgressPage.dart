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
                  _header("Your Weekly Summary"),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: "Weekly Calories",
                          value: weeklyData
                              .fold<int>(
                                0,
                                (sum, row) =>
                                    sum + safeInt(row['total_calories']),
                              )
                              .toString(),

                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: "Avg Daily Calories",
                          value:
                              (weeklyData.isEmpty
                                      ? 0
                                      : (weeklyData.fold<int>(
                                                  0,
                                                  (sum, row) =>
                                                      sum +
                                                      safeInt(
                                                        row['total_calories'],
                                                      ),
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
                          value:
                              weeklyData
                                  .fold<int>(
                                    0,
                                    (sum, row) =>
                                        sum + safeInt(row['total_protein']),
                                  )
                                  .toString() +
                              " g",

                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: "Total Sugar",
                          value:
                              weeklyData
                                  .fold<int>(
                                    0,
                                    (sum, row) =>
                                        sum + safeInt(row['total_sugar']),
                                  )
                                  .toString() +
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

                  _header("Best & Worst Choices"),
                  const SizedBox(height: 12),

                  if (weeklyData.isEmpty) const Text("No data available"),
                  if (weeklyData.isNotEmpty) ...[
                    _bestWorstTile(
                      "Best Choice",
                      _getTopFood(weeklyData, best: true),
                      Icons.thumb_up,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _bestWorstTile(
                      "Needs Improvement",
                      _getTopFood(weeklyData, best: false),
                      Icons.thumb_down,
                      Colors.red,
                    ),
                  ],

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

  Map<String, dynamic> _getTopFood(List data, {required bool best}) {
    data.sort(
      (a, b) => (a['health_score'] ?? 0).compareTo(b['health_score'] ?? 0),
    );
    return best ? data.last : data.first;
  }

  Widget _bestWorstTile(String title, Map row, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              Text(row['top_food'] ?? "Unknown food"),
              Text("Health Score: ${row['health_score'] ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proteinTrendChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              weeklyData.length,
              (i) => FlSpot(
                i.toDouble(),
                (weeklyData[i]['total_protein'] ?? 0).toDouble(),
              ),
            ),
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weeklyData.length)
                  return const SizedBox();
                return Text(
                  weeklyData[index]['date'].substring(5),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
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

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

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
                if (index < 0 || index >= data.length) return const SizedBox();
                final date = data[index]['date'].substring(5);
                return Text(date, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                final date = data[index]['date'].substring(5);
                return Text(date, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: fat,
                          color: Colors.red,
                          title:
                              "Fat ${(fat / total * 100).toStringAsFixed(0)}%",
                          radius: 45,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: protein,
                          color: Colors.green,
                          title:
                              "Protein ${(protein / total * 100).toStringAsFixed(0)}%",
                          radius: 45,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
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
