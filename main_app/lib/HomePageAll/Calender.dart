import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  final Function(String) onDateChange;

  const Calender({super.key, required this.onDateChange});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });

    String selected = day.toString().split(" ")[0];
    widget.onDateChange(selected);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.95,
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF1F8E9),
                Color(0xFFE8F5E9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            rowHeight: screenHeight * 0.085,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2024, 01, 01),
            lastDay: DateTime.utc(2050, 12, 31),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.week,

            // 🔹 Header Style
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: screenWidth * 0.045 / textScale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: const Color(0xFF2E7D32),
                size: screenWidth * 0.06,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: const Color(0xFF2E7D32),
                size: screenWidth * 0.06,
              ),
            ),

            // 🔹 Days of Week Style
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontSize: screenWidth * 0.032,
              ),
              weekendStyle: TextStyle(
                color: Colors.red.shade300,
                fontSize: screenWidth * 0.032,
              ),
            ),

            // 🔹 Calendar Style
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,

              todayDecoration: BoxDecoration(
                color: const Color(0xFFA5D6A7),
                shape: BoxShape.circle,
              ),

              selectedDecoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),

              todayTextStyle: const TextStyle(color: Colors.black),
              selectedTextStyle: const TextStyle(color: Colors.white),

              defaultTextStyle: TextStyle(
                fontSize: screenWidth * 0.035 / textScale,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),

              weekendTextStyle: TextStyle(
                color: Colors.red.shade300,
                fontSize: screenWidth * 0.035 / textScale,
              ),

              outsideDaysVisible: false,
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // 🔹 Selected Date Display
        Text(
          'Selected Day: ${today.toString().split(" ")[0]}',
          style: TextStyle(
            fontSize: screenWidth * 0.045 / textScale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
        ),

        SizedBox(height: screenHeight * 0.01),
      ],
    );
  }
}