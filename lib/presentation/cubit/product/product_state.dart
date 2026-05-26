import 'package:hit_and_puff/data/model/category_model.dart';
import 'package:hit_and_puff/data/model/product_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final String selectedCategory;
  final ProductStatus status;
  final String? errorMessage;

  ProductState({
    required this.products,
    required this.categories,
    required this.selectedCategory,
    this.status = ProductStatus.initial, // ✅ default value
    this.errorMessage,
  });

  ProductState copyWith({
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    String? selectedCategory,
    ProductStatus? status,
    String? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      status: status ?? this.status, // ✅ always keep current status if null
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
