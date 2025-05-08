import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/styles.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = true;
  String? _savedNumber;
  final _phoneRegex = RegExp(
    r'^\+?[0-9]{8,15}$',
  ); // Simple international format validation

  @override
  void initState() {
    super.initState();
    _loadSavedNumber();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNumber = prefs.getString('saved_phone_number');
      if (_savedNumber != null) {
        _phoneController.text = _savedNumber!;
      }
    });
  }

  Future<void> _savePhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || !_phoneRegex.hasMatch(phoneNumber)) {
      setState(() => _isValid = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_phone_number', phoneNumber);

    setState(() {
      _isValid = true;
      _savedNumber = phoneNumber;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number saved successfully!')),
    );
  }

  Future<void> _retrievePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('saved_phone_number');

    if (number != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Retrieved number: $number')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number saved yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Number Manager')),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Share Entry Contact Setup',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter with country code (e.g., +15551234567)',
                errorText:
                    _isValid ? null : 'Please enter a valid phone number',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_savedNumber != null)
              Text(
                'Saved number: $_savedNumber',
                style: const TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _savePhoneNumber,
                  style: AppStyles.buttonStyle,
                  child: const Text('Save Number'),
                ),
                ElevatedButton(
                  onPressed: _retrievePhoneNumber,
                  style: AppStyles.buttonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.blueGrey),
                  ),
                  child: const Text('Retrieve Number'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
