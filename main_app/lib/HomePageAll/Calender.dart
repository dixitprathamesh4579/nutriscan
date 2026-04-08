import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  final Function(String) onDateChange;
   const Calender({super.key, required this.onDateChange});

  @override
  State<Calender> createState() => Calenderstate();
}

class Calenderstate extends State<Calender> {
  DateTime today = DateTime.now();

  void _OnDaySelected(DateTime day, DateTime focusedDay) {
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
            vertical: screenHeight * 0.008,
            horizontal: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 217, 226, 246),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.15),
                blurRadius: screenWidth * 0.03,
                offset: Offset(0, screenHeight * 0.005),
              ),
            ],
          ),
          child: TableCalendar(
            rowHeight: screenHeight * 0.09,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2024, 01, 01),
            lastDay: DateTime.utc(2050, 12, 31),
            onDaySelected: _OnDaySelected,
            calendarFormat: CalendarFormat.week,

            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: screenWidth * 0.045 / textScale,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 41, 162, 255),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Color.fromARGB(255, 41, 162, 255),
                size: screenWidth * 0.06,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Color.fromARGB(255, 41, 162, 255),
                size: screenWidth * 0.06,
              ),
            ),

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.shade100,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color.fromARGB(255, 72, 169, 243),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                fontSize: screenWidth * 0.035 / textScale,
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.redAccent.shade200,
                fontSize: screenWidth * 0.035 / textScale,
              ),
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        Text(
          'Selected Day: ${today.toString().split(" ")[0]}',
          style: TextStyle(
            fontSize: screenWidth * 0.045 / textScale,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        SizedBox(height: screenHeight * 0.01),
      ],
    );
  }
}
