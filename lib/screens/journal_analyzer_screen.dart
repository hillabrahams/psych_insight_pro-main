// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:io';
import '../utils/journal_database.dart';
import '../models/journal_entry.dart';

import 'package:url_launcher/url_launcher.dart';

class JournalAnalyzerScreen extends StatefulWidget {
  const JournalAnalyzerScreen({super.key});

  @override
  _JournalAnalyzerScreenState createState() => _JournalAnalyzerScreenState();
}

class _JournalAnalyzerScreenState extends State<JournalAnalyzerScreen> {
  final TextEditingController _controller = TextEditingController();
  String? score;
  String? text;
  String? reasoning;
  String? confidence;
  int? sentimentScore;
  int? neglect_true = 0;
  int? repair_true = 0;
  int? isNeglect = 0;
  int? isRepair = 0;
  int? isShared = 0;
  int? isBid = 0;
  JournalEntry? currentEntry;

  String? _savedPhoneNumber; // Add this variable to store the retrieved number
  int? updateId = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedPhoneNumber(); // Load the number when the screen initializes
  }

  Future<void> _loadSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPhoneNumber = prefs.getString('saved_phone_number');
    });
  }

  Future<void> sendSMS(String phoneNumber, String message) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (kDebugMode) {
        print('Could not launch SMS app');
      }
      // Optionally show an error to the user
    }
  }

  void _share() {
    final entryInput = _controller.text;
    final shareText =
        "Journal Entry:\n $entryInput\n"
        "Score: $score\n"
        "Reasoning: $reasoning\n"
        "Confidence: $confidence\n"
        "Neglect: ${isNeglect == 1 ? 'Yes' : 'No'}\n"
        "Repair: ${isRepair == 1 ? 'Yes' : 'No'}";
    "Bid: ${isBid == 1 ? 'Yes' : 'No'}";

    //update currentEntry with the latest entry
    currentEntry = JournalEntry(
      id: updateId,
      entry_text: entryInput,
      score: int.parse(score!),
      reasoning: reasoning!,
      confidence: confidence!,
      isNeglect: isNeglect!,
      isRepair: isRepair!,
      isBid: isBid!,
      isShared: 1, // Mark as shared
    );
    // Save the current entry to the database
    JournalDatabase.instance.updateEntry(currentEntry!);

    // Use the saved phone number if available, otherwise show error
    if (_savedPhoneNumber != null && _savedPhoneNumber!.isNotEmpty) {
      //sendSMS(_savedPhoneNumber!, Uri.encodeFull((shareText)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number saved for sharing')),
      );
    }

    if (kDebugMode) {
      print('[0] Sharing the following text: $shareText');
      print('[1] Using phone number: $_savedPhoneNumber');
    }
  }

  void _submitText() async {
    final entryInput = _controller.text;
    final result = await analyzeEntry(entryInput);

    if (result != null) {
      // final detectedNeglect = isNeglectFuzzy(entryInput);
      // final detectedRepair = isRepairFuzzy(entryInput);
      final newEntry = JournalEntry(
        entry_text: entryInput,
        score: result['score'],
        reasoning: result['reasoning'],
        confidence: result['confidence'].toString(),
        isNeglect: result['neglect_true'] ? 1 : 0,
        isRepair: result['repair_true'] ? 1 : 0,
        isBid: result['bid_true'] ? 1 : 0,
        isShared: 0,
      );

      updateId = await JournalDatabase.instance.insertEntry(newEntry);
      if (kDebugMode) {
        print("Inserted entry with ID for use in update: $updateId");
      }

      currentEntry = newEntry; // Update the current entry

      setState(() {
        score = result['score'].toString();
        text = result['text'];
        sentimentScore = result['score'];
        reasoning = result['reasoning'];
        confidence = result['confidence'].toString();
        isNeglect = result['neglect_true'] ? 1 : 0;
        isRepair = result['repair_true'] ? 1 : 0;
        isBid = result['bid_true'] ? 1 : 0;
        isShared = 0;
      });
    } else {
      setState(() {
        score = "Error";
        reasoning = "Could not get response from API.";
        confidence = "";
      });
    }
  }

  Future<Map<String, dynamic>?> analyzeEntry(String entryText) async {
    const String url = "https://c21c-217-180-196-104.ngrok-free.app/analyze";
    String currentUrl = url;
    int redirectCount = 0;
    const int maxRedirects = 5;

    try {
      final String requestBody = jsonEncode({"entry": entryText});

      http.Response response;
      do {
        if (kDebugMode) {
          print('Sending request to: $currentUrl');
        }

        response = await http
            .post(
              Uri.parse(currentUrl),
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
                'ngrok-skip-browser-warning': 'true',
              },
              body: requestBody,
            )
            .timeout(Duration(seconds: 25));

        if (response.statusCode == 307 ||
            response.statusCode == 301 ||
            response.statusCode == 302) {
          redirectCount++;
          String? newLocation = response.headers['location'];
          if (newLocation == null) {
            throw Exception('Redirect with no location header');
          }
          currentUrl = newLocation;

          if (kDebugMode) {
            print('Redirecting to: $currentUrl');
          }
        }
      } while ((response.statusCode == 307 ||
              response.statusCode == 301 ||
              response.statusCode == 302) &&
          redirectCount < maxRedirects);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('Error: Status code ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return null;
    }
  }

  Future<void> sendEmail({
    required String to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
  }) async {
    final params = <String, String>{};
    if (subject != null) params['subject'] = subject;
    if (body != null) params['body'] = body;
    if (cc != null && cc.isNotEmpty) params['cc'] = cc.join(',');
    if (bcc != null && bcc.isNotEmpty) params['bcc'] = bcc.join(',');

    final emailUri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: params.isNotEmpty ? params : null,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: Open webmail
        await launchUrl(
          Uri.parse('https://mail.google.com/mail/?view=cm&to=$to'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching email client: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analyze Journal Entry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Enter your journal entry",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _submitText,
              child: const Text("Analyze and Save"),
            ),
            if (score != null) ...[
              const SizedBox(height: 20),
              if (sentimentScore != null && sentimentScore! >= 1) ...[
                Image.asset('assets/images/care1.png'),
              ],
              if (sentimentScore != null && sentimentScore! <= -1) ...[
                Image.asset('assets/images/abuse1.png'),
              ],
              if (isNeglect != null && isNeglect! == 1) ...[
                Image.asset('assets/images/neglect1.png'),
              ],
              if (isRepair != null && isRepair! == 1) ...[
                Image.asset('assets/images/repair1.png'),
              ],
              Text("Score: $score", style: const TextStyle(fontSize: 18)),
              Text(
                "Reasoning: $reasoning",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Confidence: $confidence",
                style: const TextStyle(fontSize: 16),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _share,
                child: const Text("Share"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
