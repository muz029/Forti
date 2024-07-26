import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MyAccountScreen extends StatefulWidget {
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String gender = '';
  String dob = '';
  String profileImageUrl = '';
  final picker = ImagePicker();
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          email = userDoc['email'];
          gender = userDoc['gender'];
          dob = userDoc['dob'];
          profileImageUrl = userDoc['profileImageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (profileImageUrl.isNotEmpty) {
      _showImageOptionsDialog();
    } else {
      _uploadNewImage();
    }
  }

  Future<void> _uploadNewImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isUpdating = true;
      });
      _showUpdatingDialog();
      await _uploadImage(pickedFile.path);
    }
  }

  Future<void> _uploadImage(String path) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
        final uploadTask = storageRef.putFile(File(path));
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new profile image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
          isUpdating = false;
        });

        Navigator.of(context).pop(); // Close the dialog
        _showSnackBar('Profile Image Updated Successfully');
      }
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      Navigator.of(context).pop(); // Close the dialog
      print('Error updating image: $e');
    }
  }

  Future<void> _removeImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
        await storageRef.delete();

        // Remove the profile image URL from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': ''});

        setState(() {
          profileImageUrl = '';
        });

        _showSnackBar('Profile Image Removed Successfully');
      }
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Delete the user from Firebase Auth
        await user.delete();

        // Redirect to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        print('Error deleting account: $e');
        _showSnackBar('Error deleting account. Please try again.');
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue, width: 2),
        ),
        title: Center(
          child: Text(
            'Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
        content: Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
            child: Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImageOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue, width: 2),
        ),
        title: Center(
          child: Text(
            'Profile Image',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Upload New Image'),
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog
                _uploadNewImage();
              },
            ),
            if (profileImageUrl.isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Image'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showUpdatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Colors.blue, width: 2),
        ),
        title: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 15),
            Text(
              'Uploading...',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.blue,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Text(
                        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$firstName $lastName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            SizedBox(height: 13),
            Divider(),
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  Text(firstName, style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text('Last Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  Text(lastName, style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
                  Text(gender, style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold))),
                  Text(dob, style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showDeleteAccountDialog,
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text('Delete Account', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
