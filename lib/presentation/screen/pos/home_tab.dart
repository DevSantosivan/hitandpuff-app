import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/core/constant/colors.dart';
import 'package:hit_and_puff/data/model/product_model.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_state.dart';
import 'package:hit_and_puff/presentation/cubit/product/product_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/product/product_state.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_state.dart';
import 'package:hit_and_puff/presentation/screen/pos/cart_page.dart';
import 'package:hit_and_puff/presentation/widgets/category_card.dart';
import 'package:hit_and_puff/presentation/widgets/product_card.dart';
import 'package:hit_and_puff/presentation/widgets/product_bottom_modal.dart';
import 'package:intl/intl.dart';

class HomeTab extends StatefulWidget {
  final Function(ProductModel, {int qty}) addToCart;
  final double totalSales;
  final String branchId; // add this

  const HomeTab({
    super.key,
    required this.addToCart,
    required this.totalSales,
    required this.branchId, // add this
  });
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  /// CURRENCY FORMATTER para sa total sales
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );

  /// CART STATE@override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadByBranch(widget.branchId);
  }

  final List<Map<String, dynamic>> cartItems = [];

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = value);
    });
  }

  /// ADD TO CART MODAL
  void _openProductModal(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return ProductBottomModal(
          product: product,
          onAddToCart: (qty) {
            setState(() {
              cartItems.add({'product': product, 'qty': qty});
            });
          },
        );
      },
    );
  }

  /// CART MODAL
  void _openCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final total = cartItems.fold<double>(
          0,
          (sum, item) => sum + (item['product'].price * item['qty']),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Cart",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              if (cartItems.isEmpty)
                const Text(
                  "Cart is empty",
                  style: TextStyle(color: Colors.white70),
                ),

              ...cartItems.map((item) {
                final p = item['product'] as ProductModel;
                final qty = item['qty'] as int;

                return ListTile(
                  title: Text(
                    p.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Qty: $qty",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    "₱${(p.price * qty).toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.cyanAccent),
                  ),
                );
              }),

              const SizedBox(height: 12),

              Text(
                "TOTAL: ₱${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () {
                          for (var item in cartItems) {
                            widget.addToCart(item['product'], qty: item['qty']);
                          }
                          setState(() => cartItems.clear());
                          Navigator.pop(context);
                        },
                  child: const Text("Submit Sale"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ===========================
  // NEW: CALCULATE TOTAL SALES
  // ===========================
  double get totalSalesFromCart {
    return cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['product'].price * item['qty']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TOP BAR
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hit & Puff',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () async {
                      final loginState = context.read<LoginCubit>().state;

                      if (loginState is! LoginSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Not logged in")),
                        );
                        return;
                      }

                      final submitted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<TransactionCubit>(),
                            child: CartPage(
                              cartItems: cartItems,
                              branch: loginState.branch,
                            ),
                          ),
                        ),
                      );

                      if (submitted == true) {
                        setState(() => cartItems.clear());
                      }
                    },
                  ),

                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          cartItems.length.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        /// TOTAL SALES CARD
        /// TOTAL SALES CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.point_of_sale,
                      color: Colors.cyanAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Sales",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),

                      // 🔥 USE BLOC TOTAL HERE
                      BlocBuilder<TransactionCubit, TransactionState>(
                        builder: (context, state) {
                          // Loading state
                          if (state is TransactionLoading) {
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          if (state is TransactionLoaded) {
                            final totalSales = state.all.fold<double>(
                              0,
                              (sum, tx) => sum + tx.totalAmount,
                            );

                            return Text(
                              currencyFormatter.format(totalSales),
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          // Default
                          return const Text(
                            "₱0.00",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// SEARCH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search product...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// CATEGORIES
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Categories",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 70,
          child: BlocBuilder<ProductCubit, ProductState>(
            buildWhen: (p, c) =>
                p.selectedCategory != c.selectedCategory ||
                p.categories != c.categories,
            builder: (context, state) {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: state.categories.map((cat) {
                  return CategoryCard(
                    name: cat.name,
                    icon: cat.icon,
                    isSelected: cat.name == state.selectedCategory,
                    onTap: () =>
                        context.read<ProductCubit>().selectCategory(cat.name),
                  );
                }).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        /// PRODUCTS
        Expanded(
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              if (state.status == ProductStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = state.products
                  .where(
                    (p) =>
                        p.category == state.selectedCategory &&
                        p.name.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();

              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    "No products found",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ProductCard(
                    product: p,
                    onAdd: () => _openProductModal(context, p),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
