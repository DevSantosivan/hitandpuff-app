import 'package:flutter/material.dart';
import 'package:hit_and_puff/core/constant/colors.dart';
import 'package:hit_and_puff/data/model/product_model.dart';

class ProductBottomModal extends StatefulWidget {
  final ProductModel product;
  final Function(int quantity) onAddToCart;

  const ProductBottomModal({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductBottomModal> createState() => _ProductBottomModalState();
}

class _ProductBottomModalState extends State<ProductBottomModal>
    with SingleTickerProviderStateMixin {
  int quantity = 1;
  bool added = false;

  void addToCart() async {
    setState(() => added = true);

    widget.onAddToCart(quantity);

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.product.price * quantity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: added ? _successView() : _buildContent(total),
      ),
    );
  }

  /// SUCCESS UI
  Widget _successView() {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
          SizedBox(height: 10),
          Text(
            "Added to Cart",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// MAIN UI
  Widget _buildContent(double total) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// PRODUCT NAME
        Text(
          widget.product.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "₱${widget.product.price.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
        ),

        const SizedBox(height: 25),

        /// QTY CONTROLLER (modern style)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                },
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  "$quantity",
                  key: ValueKey(quantity),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        /// TOTAL
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Total: ₱${total.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 25),

        /// BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: addToCart,
            child: const Text(
              "Add to Cart",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
