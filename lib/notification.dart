import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {"title": "Security Alert", "body": "Your device detected a potential threat."},
    {"title": "Scan Complete", "body": "Your last scan completed successfully."},
    {"title": "Update Available", "body": "A new update is available. Please update your app."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                notifications[index]['title']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _showNotificationDetail(context, notifications[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, Map<String, String> notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification['title']!),
          content: Text(notification['body']!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
