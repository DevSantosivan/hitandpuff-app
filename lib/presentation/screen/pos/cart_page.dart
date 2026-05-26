import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/core/constant/colors.dart';
import 'package:hit_and_puff/data/model/product_model.dart';
import 'package:hit_and_puff/data/model/branch_model.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_state.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final BranchModel branch;

  const CartPage({super.key, required this.cartItems, required this.branch});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool submitted = false;

  void removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  void updateQty(int index, int change) {
    setState(() {
      final current = widget.cartItems[index]['qty'] as int;
      final newQty = current + change;

      if (newQty <= 0) {
        widget.cartItems.removeAt(index);
      } else {
        widget.cartItems[index]['qty'] = newQty;
      }
    });
  }

  double get total => widget.cartItems.fold<double>(
    0,
    (sum, item) => sum + (item['product'].price * item['qty']),
  );

  void submitSale(BuildContext context) {
    if (widget.cartItems.isEmpty) return;

    context.read<TransactionCubit>().submitSale(
      branch: widget.branch,
      cartItems: widget.cartItems,
    );
  }

  void clearCart() {
    setState(() {
      widget.cartItems.clear(); // 🔥 IMPORTANT FIX
      submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: AppColors.card,
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),

        child: submitted
            ? _successView()
            : widget.cartItems.isEmpty
            ? const Center(
                child: Text(
                  "Cart is empty",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : _buildCartUI(),
      ),
    );
  }

  // ======================
  // CART UI
  // ======================
  Widget _buildCartUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.cartItems.length,
            itemBuilder: (_, i) {
              final item = widget.cartItems[i];
              final p = item['product'] as ProductModel;
              final qty = item['qty'] as int;

              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => removeItem(i),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  color: AppColors.card,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "₱${p.price}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () => updateQty(i, -1),
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              "$qty",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => updateQty(i, 1),
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          "₱${(p.price * qty).toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        _buildBottomSection(),
      ],
    );
  }

  // ======================
  // TOTAL + SUBMIT
  // ======================
  Widget _buildBottomSection() {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) async {
        if (state is TransactionSuccess) {
          clearCart(); // 🔥 CLEAR + SHOW SUCCESS

          await Future.delayed(const Duration(milliseconds: 900));

          if (context.mounted) {
            Navigator.pop(context, true); // back HomeTab
          }
        }

        if (state is TransactionFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "₱${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: state is TransactionLoading
                      ? null
                      : () => submitSale(context),
                  child: state is TransactionLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Submit Sale",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================
  // SUCCESS UI
  // ======================
  Widget _successView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
            SizedBox(height: 12),
            Text(
              "Sale Submitted",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
