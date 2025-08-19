import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for web check

import 'package:petzyadmin/bloc/admin_orders_filter_bloc.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/product_bloc.dart';
import 'package:petzyadmin/screens/authwraper_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web-specific Firebase initialization
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCGAejlobb4F1Y8cDtfL46TrpF8UMDuAbA",
        authDomain: "petzy-9fe50.firebaseapp.com",
        projectId: "petzy-9fe50",
        storageBucket: "petzy-9fe50.firebasestorage.app",
        messagingSenderId: "843413589602",
        appId: "1:843413589602:web:f8d6ea9d26bcdb2128cb3b",
        measurementId: "G-PEH8PV5KQ9",
      ),
    );
  } else {
    // Mobile initialization (Android/iOS)
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(
          create: (_) => CategoryBloc()..add(LoadCategoriesEvent()),
        ),
        BlocProvider<AddProductBloc>(create: (_) => AddProductBloc()),
        BlocProvider<AdminOrdersFilterBloc>(
          create: (context) => AdminOrdersFilterBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Petzy Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
