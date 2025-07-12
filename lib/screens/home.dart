import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/widgets/shimmer.dart';
import 'package:petzyadmin/bloc/user_search_cubit.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final TextEditingController _searchController = TextEditingController();

    return BlocProvider(
      create: (_) => UserSearchCubit(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<UserSearchCubit, String>(
                builder: (context, state) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: whiteColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged:
                        (value) => context
                            .read<UserSearchCubit>()
                            .updateSearchQuery(value),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<UserSearchCubit, String>(
                builder: (context, searchQuery) {
                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        usersRef
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: redColor),
                          ),
                        );
                      }

                      // ✅ Show shimmer while loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ShimmerPlaceholder();
                      }

                      final docs = snapshot.data?.docs ?? [];

                      final filteredDocs =
                          docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? '').toLowerCase();
                            final email = (data['email'] ?? '').toLowerCase();
                            return name.contains(searchQuery.toLowerCase()) ||
                                email.contains(searchQuery.toLowerCase());
                          }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            'No users found.',
                            style: TextStyle(color: greyColor),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final data =
                              filteredDocs[index].data()
                                  as Map<String, dynamic>;
                          return Card(
                            color: whiteColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            shadowColor: greyColor.withOpacity(0.3),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              title: Text(
                                data['name'] ?? 'No Name',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['email'] ?? 'No Email',
                                      style: TextStyle(
                                        color: greyColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if ((data['phone'] ?? '').isNotEmpty)
                                      Text(
                                        data['phone'],
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.2),
                                child: Text(
                                  (data['name'] != null &&
                                          data['name'].isNotEmpty)
                                      ? data['name'][0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
