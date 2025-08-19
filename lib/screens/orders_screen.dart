import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_event.dart';
import 'package:petzyadmin/bloc/admin_orders_filter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/widgets/admin_orders_filter_widget.dart';
import 'package:petzyadmin/widgets/admin_orders_list.dart';
import 'package:petzyadmin/widgets/responsive.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminOrdersBloc>().add(LoadAllOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminOrdersFilterBloc(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: ResponsiveLayout(
          mobile:
              (_) => const Column(
                children: [
                  AdminOrdersFilterWidget(),
                  Expanded(child: AdminOrdersList()),
                ],
              ),
          tablet:
              (_) => const Row(
                children: [
                  Expanded(flex: 2, child: AdminOrdersFilterWidget()),
                  Expanded(flex: 5, child: AdminOrdersList()),
                ],
              ),
          desktop:
              (_) => const Row(
                children: [
                  Expanded(flex: 1, child: AdminOrdersFilterWidget()),
                  Expanded(flex: 4, child: AdminOrdersList()),
                ],
              ),
        ),
      ),
    );
  }
}
