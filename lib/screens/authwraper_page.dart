import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petzyadmin/screens/admin_screen.dart';
import 'package:petzyadmin/screens/home.dart';
import 'package:petzyadmin/screens/signin_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> checkIfAdmin(User user) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      print('User document data: $data');
      if (data == null) return false;
      // Use exact Firestore field name from your data
      final isAdmin = data['isadmin'] ?? false;
      print('isadmin field value: $isAdmin');
      return isAdmin == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return FutureBuilder<bool>(
              future: checkIfAdmin(user),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (adminSnapshot.hasData &&
                    adminSnapshot.data == true) {
                  return AdminDashboard(); // Only if admin
                } else {
                  FirebaseAuth.instance.signOut(); // Force logout if not admin
                  return SignInPage();
                }
              },
            );
          } else {
            return SignInPage();
          }
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
