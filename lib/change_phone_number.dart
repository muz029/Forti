import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'settings.dart'; // Import the SettingsScreen

class ChangePhoneNumberScreen extends StatefulWidget {
  @override
  _ChangePhoneNumberScreenState createState() => _ChangePhoneNumberScreenState();
}

class _ChangePhoneNumberScreenState extends State<ChangePhoneNumberScreen> {
  String phoneNumber = '';
  String newPhoneNumber = '';
  PhoneNumber number = PhoneNumber(isoCode: 'PK');
  bool _isUpdating = false; // New variable to track updating state

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        setState(() {
          phoneNumber = userDoc['phoneNumber'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching phone number: $e");
    }
  }

  Future<void> _updatePhoneNumber() async {
    if (newPhoneNumber.isEmpty) {
      _showDialog('Error', 'Please enter a valid phone number.', false);
      return;
    }

    if (newPhoneNumber == phoneNumber) {
      _showDialog('Error', 'This number is already your current phone number.', false);
      return;
    }

    setState(() {
      _isUpdating = true; // Start loading indicator
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'phoneNumber': newPhoneNumber});

        _showDialog('Success', 'Phone number updated successfully.', true);
      }
    } catch (e) {
      _showDialog('Error', 'Failed to update phone number. Please try again.', false);
    } finally {
      setState(() {
        _isUpdating = false; // Stop loading indicator
      });
    }
  }

  void _showDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: Colors.blue, width: 2),
          ),
          title: Center(
            child: Text(
              title,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isSuccess) {
                    _fetchPhoneNumber(); // Refresh the phone number
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Okay',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangePhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: Colors.blue, width: 2),
          ),
          title: Text(
            'Enter New Number',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  newPhoneNumber = number.phoneNumber!;
                },
                initialValue: number,
                inputDecoration: InputDecoration(
                  hintText: 'New Number',
                  border: OutlineInputBorder(),
                ),
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                formatInput: false,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updatePhoneNumber();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: _isUpdating
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Phone Number',
          style: TextStyle(color: Colors.white),
        ),
        leadingWidth: 80,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Phone Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              controller: TextEditingController(text: phoneNumber),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showChangePhoneNumberDialog,
              child: Text(
                'Change Phone Number',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
