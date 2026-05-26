import 'package:equatable/equatable.dart';
import 'package:hit_and_puff/data/model/transaction_fetch_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {}

class TransactionFailure extends TransactionState {
  final String error;

  const TransactionFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class TransactionLoaded extends TransactionState {
  final List<TransactionFetchModel> all;
  final List<TransactionFetchModel> returned;

  const TransactionLoaded({required this.all, required this.returned});
}
