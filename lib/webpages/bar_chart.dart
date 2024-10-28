import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatefulWidget {
  @override
  _SimpleBarChartState createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  int scheduledCount = 0;
  int completedCount = 0;
  int canceledCount = 0;
  int missedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAppointmentCounts();
  }

  Future<void> fetchAppointmentCounts() async {
    final snapshot = await FirebaseFirestore.instance.collection('bookings').get();

    int scheduled = 0;
    int completed = 0;
    int canceled = 0;
    int missed = 0;

    for (var doc in snapshot.docs) {
      final status = doc['status'];
      if (status == 'scheduled') {
        scheduled++;
      } else if (status == 'completed') {
        completed++;
      } else if (status == 'canceled' || status == 'canceled by admin') {
        canceled++;
      } else if (status == 'missed') {
        missed++;
      }
    }

    setState(() {
      scheduledCount = scheduled;
      completedCount = completed;
      canceledCount = canceled;
      missedCount = missed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Bar Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(150),
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            barGroups: _generateBarGroups(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Scheduled');
                      case 1:
                        return const Text('Completed');
                      case 2:
                        return const Text('Canceled');
                      case 3:
                        return const Text('Missed');
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY}',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: scheduledCount.toDouble(), color: Colors.blue, width: 50, borderRadius: BorderRadius.circular(4))]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: completedCount.toDouble(), color: Colors.green, width: 50, borderRadius: BorderRadius.circular(4))]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: canceledCount.toDouble(), color: Colors.red, width: 50, borderRadius: BorderRadius.circular(4))]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: missedCount.toDouble(), color: Colors.orange, width: 50, borderRadius: BorderRadius.circular(4))]),
    ];
  }
}
