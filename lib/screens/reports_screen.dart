// Full reports_screen.dart with TTS voice playback for entries

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../styles.dart';
import '../utils/notification_service.dart';
import '../utils/db_helper.dart';
import '../models/journal_entry.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  List<JournalEntry> _entries = [];
  final DBHelper _dbHelper = DBHelper();
  final FlutterTts flutterTts = FlutterTts();
  bool _loading = false;
  JournalEntry? _selectedEntry;

  Future<void> _speakEntry(JournalEntry entry) async {
    await flutterTts.stop();
    final String message =
        'Score: ${entry.score}. '
        '${entry.entry_text}. '
        'Reasoning: ${entry.reasoning}. '
        'Confidence: ${entry.confidence}. '
        'Neglect: ${entry.isNeglect == 1 ? "Yes" : "No"}.';
    'Repair: ${entry.isRepair == 1 ? "Yes" : "No"}.';
    await flutterTts.speak(message);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _toDateTimeString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final nowMinus7 = DateTime.now().subtract(const Duration(days: 7));
    final initial = isStart ? (_startDate ?? nowMinus7) : (_endDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _loadEntries() async {
    if (_startDate == null || _endDate == null) {
      NotificationService.showWarningDialog(
        context,
        'Please select both start and end dates.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _entries = [];
      _selectedEntry = null;
    });

    final start = _toDateTimeString(_startDate!);
    final end = _toDateTimeString(
      _endDate!
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1)),
    );

    try {
      final results = await _dbHelper.getEntriesBetweenDates(start, end);
      setState(() {
        _entries = results;
      });
    } catch (e) {
      if (mounted) {
        NotificationService.showErrorDialog(context, 'Failed to load entries.');
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildLineChart(double width) {
    if (_entries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data to chart')),
      );
    }

    final timestamps = <String>[];
    final scoreSpots = <FlSpot>[];
    final regressionSpots = <FlSpot>[];
    bool useSlopeforlineColor = false;
    Color lineColor = Colors.green; // Define lineColor with a default value

    List<double> xVals = [];
    List<double> yVals = [];

    for (int i = 0; i < _entries.length; i++) {
      final x = i.toDouble();
      final y = _entries[i].score.toDouble();
      if (y >= -10 && y <= 0) {
        useSlopeforlineColor = true;
      }
      scoreSpots.add(FlSpot(x, y));
      timestamps.add(_entries[i].timestamp ?? 'Entry $i');
      xVals.add(x);
      yVals.add(y);
    }

    final n = xVals.length;
    final xSum = xVals.reduce((a, b) => a + b);
    final ySum = yVals.reduce((a, b) => a + b);
    final xySum = List.generate(
      n,
      (i) => xVals[i] * yVals[i],
    ).reduce((a, b) => a + b);
    final xSqSum = xVals.map((x) => x * x).reduce((a, b) => a + b);
    final slope = (n * xySum - xSum * ySum) / (n * xSqSum - xSum * xSum);
    final intercept = (ySum - slope * xSum) / n;

    if (useSlopeforlineColor) {
      lineColor =
          slope >= 0
              ? Colors.green
              : Colors.red; // Update lineColor based on slope
    } else {
      lineColor = Colors.green; // Default color if slope is not used
    }

    regressionSpots.addAll(xVals.map((x) => FlSpot(x, slope * x + intercept)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Sentiment Analysis for ${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          height: 300,
          child: LineChart(
            LineChartData(
              minX: -0.5,
              maxX: (_entries.length - 1).toDouble() + 0.5,
              minY: -10,
              maxY: 10,
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  top: BorderSide(),
                  right: BorderSide(),
                  bottom: BorderSide(width: 1.5),
                  left: BorderSide(),
                ),
              ),
              gridData: FlGridData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: scoreSpots,
                  isCurved: false,
                  barWidth: 0,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) {
                      final color =
                          (spot.y >= 1 && spot.y <= 10)
                              ? Colors.green
                              : Colors.red;
                      return FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 1,
                        strokeColor: Colors.black,
                      );
                    },
                  ),
                ),
                LineChartBarData(
                  spots: regressionSpots,
                  isCurved: false,
                  color: lineColor,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 40,
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < timestamps.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              timestamps[index].split(' ').first,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, _) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions || response == null) {
                    return;
                  }
                  final spot = response.lineBarSpots?.first;
                  if (spot != null) {
                    final index = spot.x.toInt();
                    if (index >= 0 && index < _entries.length) {
                      setState(() {
                        _selectedEntry = _entries[index];
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(width: 12, height: 12, color: lineColor),
              const SizedBox(width: 6),
              const Text('Trend Line', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        //   if (_selectedEntry != null) ...[
        //     const SizedBox(height: 10),
        //     Container(
        //       padding: const EdgeInsets.all(12),
        //       decoration: BoxDecoration(
        //         color: Colors.grey[200],
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Row(
        //             children: [
        //               const Text(
        //                 'Entry Details',
        //                 style: TextStyle(fontWeight: FontWeight.bold),
        //               ),
        //               const Spacer(),
        //               IconButton(
        //                 icon: const Icon(Icons.volume_up),
        //                 onPressed: () => _speakEntry(_selectedEntry!),
        //               ),
        //               IconButton(
        //                 icon: const Icon(Icons.close),
        //                 onPressed: () => setState(() => _selectedEntry = null),
        //               ),
        //             ],
        //           ),
        //           Text(
        //             'Score: ${_selectedEntry!.score}',
        //             style: const TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //           const SizedBox(height: 4),
        //           Text(_selectedEntry!.text),
        //           const SizedBox(height: 8),
        //           const Text(
        //             'Reasoning:',
        //             style: TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //           Text(_selectedEntry!.reasoning),
        //           const SizedBox(height: 8),
        //           Text('Confidence: ${_selectedEntry!.confidence}'),
        //           Text('Neglect: ${_selectedEntry!.isNeglect ? "Yes" : "No"}'),
        //         ],
        //       ),
        //     ),
        //   ],
        // ],
        if (_selectedEntry != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white, // Tooltip background
              borderRadius: BorderRadius.circular(10),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.blue,
              ), // All tooltip text in blue
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Entry Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speakEntry(_selectedEntry!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selectedEntry = null),
                      ),
                    ],
                  ),
                  Text(
                    'Score: ${_selectedEntry!.score}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_selectedEntry!.entry_text),
                  const SizedBox(height: 8),
                  const Text(
                    'Reasoning:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_selectedEntry!.reasoning),
                  const SizedBox(height: 8),
                  Text('Confidence: ${_selectedEntry!.confidence}'),
                  Text(
                    'Neglect: ${_selectedEntry!.isNeglect == 1 ? "Yes" : "No"}'
                    ' Repair: ${_selectedEntry!.isRepair == 1 ? "Yes" : "No"}',
                  ),
                  Text(
                    'Date & Time: ${_selectedEntry!.timestamp != null ? DateFormat('MM-dd-yyyy hh:mm:ss').format(DateTime.parse(_selectedEntry!.timestamp!)) : "Invalid date"}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Reports', style: AppStyles.heading)),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: AppStyles.buttonStyle,
                            onPressed: () => _pickDate(isStart: true),
                            child: Text('>=  ${_formatDate(_startDate)}'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: AppStyles.buttonStyle,
                            onPressed: () => _pickDate(isStart: false),
                            child: Text('<=  ${_formatDate(_endDate)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: AppStyles.buttonStyle,
                      onPressed: _loadEntries,
                      child: const Text('Load Report'),
                    ),
                    const SizedBox(height: 16),
                    _buildLineChart(screenWidth),
                  ],
                ),
              ),
    );
  }
}
