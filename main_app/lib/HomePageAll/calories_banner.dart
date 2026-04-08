import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Calories extends StatefulWidget {
  final double totalCalories;

  const Calories({super.key, required this.totalCalories});

  @override
  State<Calories> createState() => CaloriesState();
}

class CaloriesState extends State<Calories> {
  double? target;

  @override
  void initState() {
    super.initState();
    fetchTarget();
  }

  Future<void> fetchTarget() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    print("Fetching target for user: ${user?.id}");

    final response = await supabase
        .from('profiles')
        .select('calorie_target')
        .eq('id', user!.id)
        .maybeSingle();

    setState(() {
      target = response?['calorie_target'] != null
          ? (response!['calorie_target'] as num).toDouble()
          : 2000;
    });
  }

  Future<void> saveNewTarget(double newTarget) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    await supabase.from('profiles').upsert({
      'id': user!.id,
      'calorie_target': newTarget,
    });

    setState(() => target = newTarget);
  }

  void showTargetDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Calorie Target"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Target (Kcal)"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null) {
                await saveNewTarget(value);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    final double shownTarget = target ?? 2000;
    final bool exceeded = widget.totalCalories > shownTarget;

    final Color mainTextColor = exceeded ? Colors.red : Colors.white;
    final Color subTextColor = exceeded ? Colors.redAccent : Colors.white70;
    final Color progressColor = exceeded ? Colors.red : Colors.white;

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.22,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 248, 187, 45),
            Color.fromARGB(255, 252, 199, 85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Calories",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.06 / textScale,
                  color:  mainTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: showTargetDialog,
                child: const Icon(Icons.refresh, color: Colors.white, size: 26),
              ),
            ],
          ),

          Text(
            '${widget.totalCalories.toStringAsFixed(0)} Kcal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.075 / textScale,
              color: subTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            'Target - ${shownTarget.toStringAsFixed(0)} Kcal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035 / textScale,
              color: progressColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          LinearPercentIndicator(
            width: screenWidth * 0.83,
            lineHeight: screenHeight * 0.015,
            percent: (widget.totalCalories / shownTarget).clamp(0.0, 1.0),
            animation: true,
            animationDuration: 1000,
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
            barRadius: Radius.circular(screenWidth * 0.03),
          ),
        ],
      ),
    );
  }
}
