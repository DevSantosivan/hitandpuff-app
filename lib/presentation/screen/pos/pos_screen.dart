import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/core/constant/colors.dart';
import 'package:hit_and_puff/data/model/branch_model.dart';
import 'package:hit_and_puff/data/model/cart_item_model.dart';
import 'package:hit_and_puff/data/model/product_model.dart';
import 'package:hit_and_puff/presentation/cubit/product/product_cubit.dart';
import 'package:hit_and_puff/presentation/screen/pos/profile_tab.dart';
import 'home_tab.dart';
import 'package:hit_and_puff/presentation/screen/transaction_tab.dart';

class PosMobileScreen extends StatefulWidget {
  final BranchModel branch;
  const PosMobileScreen({super.key, required this.branch});

  @override
  State<PosMobileScreen> createState() => _PosMobileScreenState();
}

class _PosMobileScreenState extends State<PosMobileScreen> {
  int _currentIndex = 0;
  final List<CartItemModel> _cart = [];

  void _addToCart(ProductModel product, {int qty = 1}) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        _cart[index].qty += qty;
      } else {
        _cart.add(CartItemModel(product: product, qty: qty));
      }
    });
  }

  double get totalAmount =>
      _cart.fold(0, (sum, item) => sum + item.product.price * item.qty);

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 0:
      case 0:
        body = BlocProvider(
          create: (_) => ProductCubit(),
          child: HomeTab(
            addToCart: _addToCart,
            totalSales: totalAmount,
            branchId: widget.branch.id.toString(), // <--- pass branch
          ),
        );
        break;

        break;
      case 1:
        body = TransactionTab(
          cart: _cart,
          branchId: widget.branch.id.toString(), // <-- add this
        );
        break;

      case 2:
        body = ProfilePage(branch: widget.branch);
        break;
      default:
        body = const SizedBox();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ' Account'),
        ],
      ),
    );
  }
}
