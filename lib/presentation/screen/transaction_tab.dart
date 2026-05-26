import 'package:flutter/material.dart';

import 'package:hit_and_puff/data/model/cart_item_model.dart';
import 'package:hit_and_puff/data/model/transaction_fetch_model.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_state.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionTab extends StatefulWidget {
  final List<CartItemModel> cart;
  final String branchId;

  const TransactionTab({super.key, required this.cart, required this.branchId});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  List<TransactionFetchModel> allTransactions = [];
  List<TransactionFetchModel> returnedTransactions = [];

  bool loading = true;
  int _currentTab = 0;

  DateTime selectedDate = DateTime.now();

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );

  // Category Icons List
  final List<CategoryModel> categories = [
    CategoryModel(name: 'Disposable', icon: Icons.smoking_rooms),
    CategoryModel(name: 'Pod', icon: Icons.device_hub),
    CategoryModel(name: 'Juice', icon: Icons.local_drink),
    CategoryModel(name: 'Mods', icon: Icons.electrical_services),
    CategoryModel(name: 'Coils', icon: Icons.loop),
    CategoryModel(name: 'Pods Cartridge', icon: Icons.charging_station),
    CategoryModel(name: 'Accessories', icon: Icons.build),
    CategoryModel(name: 'Batteries', icon: Icons.battery_full),
    CategoryModel(name: 'Chargers', icon: Icons.power),
    CategoryModel(name: 'Cotton & Wires', icon: Icons.construction),
  ];

  @override
  void initState() {
    super.initState();

    context.read<TransactionCubit>().loadTransactions(widget.branchId);
  }

  // Filter transactions by selected date
  // List<TransactionFetchModel> get transactionsByDate {
  //   return allTransactions.where((tx) {
  //     final createdAt = DateTime.parse(tx.createdAt.toString());
  //     return createdAt.year == selectedDate.year &&
  //         createdAt.month == selectedDate.month &&
  //         createdAt.day == selectedDate.day;
  //   }).toList();
  // }

  // double get todayTotal =>
  //     transactionsByDate.fold(0, (sum, tx) => sum + tx.totalAmount);

  // double get finishedTotal => allTransactions
  //     .where((tx) => tx.isReturned == true)
  //     .fold(0, (sum, tx) => sum + tx.totalAmount);
  Future<void> _returnTransaction(TransactionFetchModel tx) async {
    await context.read<TransactionCubit>().updateReturnedStatus(
      transactionId: tx.id,
      isReturned: true,
      branchId: widget.branchId,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Get category icon based on category name
  IconData getCategoryIcon(String categoryName) {
    final found = categories.firstWhere(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => CategoryModel(name: 'Unknown', icon: Icons.category),
    );
    return found.icon;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transaction',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // DATE PICKER BUTTON
            Row(
              children: [
                Text(
                  "Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectDate,
                  child: const Text(
                    "Change Date",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TOTAL CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.point_of_sale,
                      color: Colors.cyan,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Transaction",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Summary",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      double allTotal = 0;
                      double returnedTotal = 0;

                      if (state is TransactionLoaded) {
                        allTotal = state.all
                            .where((tx) {
                              final createdAt = DateTime.parse(
                                tx.createdAt.toString(),
                              );

                              return tx.isReturned == false &&
                                  createdAt.year == selectedDate.year &&
                                  createdAt.month == selectedDate.month &&
                                  createdAt.day == selectedDate.day;
                            })
                            .fold(0.0, (sum, tx) => sum + tx.totalAmount);

                        returnedTotal = state.returned
                            .where((tx) {
                              final createdAt = DateTime.parse(
                                tx.createdAt.toString(),
                              );

                              return createdAt.year == selectedDate.year &&
                                  createdAt.month == selectedDate.month &&
                                  createdAt.day == selectedDate.day;
                            })
                            .fold(0.0, (sum, tx) => sum + tx.totalAmount);
                      }

                      return Text(
                        _currentTab == 0
                            ? '₱${currencyFormatter.format(allTotal)}'
                            : '₱${currencyFormatter.format(returnedTotal)}',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TAB BAR
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                onTap: (index) {
                  setState(() => _currentTab = index);
                },
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.grey.shade400,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.point_of_sale, size: 18),
                          SizedBox(width: 6),
                          Text("Sales"),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_return, size: 18),
                          SizedBox(width: 6),
                          Text("Returned"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TransactionFailure) {
                    return Center(child: Text(state.error));
                  }
                  if (state is TransactionLoaded) {
                    final allTransactions = state.all;
                    final returnedTransactions = state.returned;

                    // FILTER ALL
                    final filteredAll = allTransactions.where((tx) {
                      final createdAt = DateTime.parse(tx.createdAt.toString());

                      return tx.isReturned == false &&
                          createdAt.year == selectedDate.year &&
                          createdAt.month == selectedDate.month &&
                          createdAt.day == selectedDate.day;
                    }).toList();

                    // FILTER RETURNED
                    final filteredReturned = returnedTransactions.where((tx) {
                      final createdAt = DateTime.parse(tx.createdAt.toString());

                      return tx.isReturned == true &&
                          createdAt.year == selectedDate.year &&
                          createdAt.month == selectedDate.month &&
                          createdAt.day == selectedDate.day;
                    }).toList();

                    // ✅ TOTALS
                    final todayTotal = filteredAll.fold<double>(
                      0,
                      (sum, tx) => sum + tx.totalAmount,
                    );

                    final finishedTotal = filteredReturned.fold<double>(
                      0,
                      (sum, tx) => sum + tx.totalAmount,
                    );

                    return Column(
                      children: [
                        const SizedBox(height: 12),

                        // ✅ TAB CONTENT
                        Expanded(
                          child: TabBarView(
                            children: [
                              loadingWidget(
                                list: filteredAll,
                                emptyText: "No transactions yet",
                                isReturned: false,
                              ),

                              loadingWidget(
                                list: filteredReturned,
                                emptyText: "No returned transactions",
                                isReturned: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadingWidget({
    required List<TransactionFetchModel> list,
    required String emptyText,
    required bool isReturned,
  }) {
    if (list.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final tx = list[i];

        final created = DateTime.parse(tx.createdAt.toString());
        final formattedTime = DateFormat(
          'MMM dd, yyyy hh:mm a',
        ).format(created);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isReturned ? Colors.grey.shade800 : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReturned
                    ? 'Returned - $formattedTime'
                    : 'Transaction - $formattedTime',
                style: TextStyle(
                  color: isReturned ? Colors.cyan : Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 6),

              ...tx.items.map(
                (item) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          getCategoryIcon(item.category),
                          color: Colors.cyanAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.productName} x${item.qty}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Text(
                      '₱${currencyFormatter.format(item.subtotal)}',
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Total: ₱${currencyFormatter.format(tx.totalAmount)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (!isReturned)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showReturnDialog(tx),
                    child: const Text(
                      "Return",
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showReturnDialog(TransactionFetchModel tx) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            "Confirm Return",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to return this transaction?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                _returnTransaction(tx);

                // ✅ SUCCESS MODAL UI (REPLACES SNACKBAR)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    });

                    return Dialog(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.cyanAccent,
                              size: 70,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Successfully Returned",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text(
                "Yes, Return",
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Category Model
class CategoryModel {
  final String name;
  final IconData icon;

  CategoryModel({required this.name, required this.icon});
}
