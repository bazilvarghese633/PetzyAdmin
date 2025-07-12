import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/dashboard_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/add_category.dart';
import 'package:petzyadmin/screens/add_products.dart';
import 'package:petzyadmin/screens/home.dart';
import 'package:petzyadmin/screens/product_list.dart';
import 'package:petzyadmin/widgets/shimmer.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  final List<Widget> _screens = [
    UsersListPage(),
    AddCategoryPage(),
    AddProductPage(),
    ProductListPage(),
  ];

  final List<String> _titles = [
    'All Users',
    'Add Category',
    'Add Product',
    'My Products',
  ];

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final selectedIndex = state.selectedIndex;

          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: Text(_titles[selectedIndex]),
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
            body:
                state.isLoading
                    ? const ShimmerPlaceholder()
                    : _screens[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: whiteColor,
              selectedItemColor: primaryColor,
              unselectedItemColor: greyColor,
              currentIndex: selectedIndex,
              onTap: (index) {
                context.read<DashboardBloc>().add(DashboardTabChanged(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Category',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_box),
                  label: 'Product',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt),
                  label: 'My Products',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
