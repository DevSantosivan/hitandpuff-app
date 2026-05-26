import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/category_model.dart';
import '../../../data/model/product_model.dart';
import '../../../core/service/api_service.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit()
    : super(
        ProductState(
          products: [],
          categories: [],
          selectedCategory: 'Disposable',
          status: ProductStatus.initial,
        ),
      ) {
    loadInitialData();
  }

  StreamSubscription? _productSubscription;

  // =========================
  // INIT
  // =========================
  Future<void> loadInitialData() async {
    if (isClosed) return;

    emit(state.copyWith(status: ProductStatus.loading));

    try {
      // STATIC CATEGORIES
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

      emit(state.copyWith(categories: categories));

      // START REALTIME STREAM
      _startProductStream();
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================
  // REALTIME STREAM
  // =========================
  Future<void> _startProductStream() async {
    if (isClosed) return;

    await _productSubscription?.cancel();

    try {
      _productSubscription = ApiService.streamProductsFromProfileBranch()
          .listen(
            (products) {
              if (isClosed) return;

              emit(
                state.copyWith(
                  products: products,
                  status: ProductStatus.success,
                ),
              );
            },
            onError: (error) {
              if (isClosed) return;

              emit(
                state.copyWith(
                  status: ProductStatus.failure,
                  errorMessage: error.toString(),
                ),
              );
            },
          );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================
  // CATEGORY SELECT
  // =========================
  void selectCategory(String category) {
    if (isClosed) return;

    emit(state.copyWith(selectedCategory: category));
  }

  // =========================
  // CLEANUP
  // =========================
  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
