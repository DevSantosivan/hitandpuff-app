import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/core/service/transaction/api_transaction_service.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_state.dart';
import '../../../data/model/branch_model.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());

  /// ✅ LOAD BOTH ALL + RETURNED IN ONE GO
  Future<void> loadAll(String branchId) async {
    emit(TransactionLoading());

    try {
      final all = await TransactionService.fetchTransactionsByBranch(branchId);

      final returned =
          await TransactionService.fetchReturnedTransactionsByBranch(branchId);

      emit(TransactionLoaded(all: all, returned: returned));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  /// (optional alias mo kung ginagamit mo pa)
  Future<void> loadTransactions(String branchId) async {
    await loadAll(branchId);
  }

  /// (optional alias mo kung ginagamit mo pa)
  Future<void> loadByBranch(String branchId) async {
    await loadAll(branchId);
  }

  /// ✅ UPDATE RETURN STATUS + AUTO REFRESH
  Future<void> updateReturnedStatus({
    required String transactionId,
    required bool isReturned,
    required String branchId,
  }) async {
    emit(TransactionLoading());

    try {
      await TransactionService.updateReturnedStatus(
        transactionId: transactionId,
        isReturned: isReturned,
      );

      // 🔥 refresh both lists after update
      final all = await TransactionService.fetchTransactionsByBranch(branchId);

      final returned =
          await TransactionService.fetchReturnedTransactionsByBranch(branchId);

      emit(TransactionLoaded(all: all, returned: returned));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  /// OPTIONAL: submit sale then refresh
  Future<void> submitSale({
    required BranchModel branch,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    emit(TransactionLoading());

    try {
      await TransactionService.submitSale(branch: branch, cartItems: cartItems);

      final all = await TransactionService.fetchTransactionsByBranch(branch.id);

      final returned =
          await TransactionService.fetchReturnedTransactionsByBranch(branch.id);

      emit(TransactionLoaded(all: all, returned: returned));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }
}
