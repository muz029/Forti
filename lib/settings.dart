import 'package:flutter/material.dart';
import 'my_account.dart'; // Import the MyAccountScreen
import 'change_password.dart'; // Import the ChangePasswordScreen
import 'change_phone_number.dart';  // Import the ChangePhoneNumberScreen

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool areNotificationsEnabled = true; // Default to notifications being enabled

  void _toggleNotifications(bool value) {
    setState(() {
      areNotificationsEnabled = value;
    });
    // Handle any additional logic here, like saving the preference
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.blue),
            title: Text('Language'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('English'),
                Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ],
            ),
            onTap: () {
              // Language setting (currently disabled)
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.blue),
            title: Text('Push Notifications'),
            trailing: Switch(
              value: areNotificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue),
            title: Text('My Account'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyAccountScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.blue),
            title: Text('Change Password'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.blue),
            title: Text('Change Phone Number'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ChangePhoneNumberScreen()),
              ); // Navigate to change phone number screen
            },
          ),
        ],
      ),
    );
  }
}
