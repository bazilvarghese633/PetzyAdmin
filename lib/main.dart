import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/product_bloc.dart';
import 'package:petzyadmin/screens/authwraper_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
        BlocProvider<AddProductBloc>(
          create: (_) => AddProductBloc(), // ✅ Using the correct product bloc
        ),
        // Add more BLoCs here as needed
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
