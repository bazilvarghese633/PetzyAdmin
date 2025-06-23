import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/add_category.dart';
import 'package:petzyadmin/screens/add_products.dart';
import 'package:petzyadmin/screens/home.dart';
import 'package:petzyadmin/screens/product_list.dart';
// ✅ import

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    UsersListPage(),
    AddCategoryPage(),
    AddProductPage(),
    ProductListPage(), // ✅ added
  ];

  final List<String> _titles = [
    'All Users',
    'Add Category',
    'Add Product',
    'My Products', // ✅ added
  ];

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
            color: whiteColor,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: whiteColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Product'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Products',
          ), // ✅ added
        ],
      ),
    );
  }
}
