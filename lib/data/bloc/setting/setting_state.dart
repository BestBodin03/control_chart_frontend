import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/types/form_state.dart';
import 'package:equatable/equatable.dart';

abstract class SettingState extends Equatable {
  const SettingState();
  
  @override
  List<Object?> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final int? chartDetailCount;
  final List<Furnace>? furnaces;
  final List<CustomerProduct>? matNumbers;

  const SettingLoaded({
    this.chartDetailCount,
    this.furnaces,
    this.matNumbers,
  });

  @override
  List<Object?> get props => [chartDetailCount, furnaces, matNumbers];

  SettingLoaded copyWith({
    int? chartDetailCount,
    List<Furnace>? furnaces,
    List<CustomerProduct>? matNumbers,
  }) {
    return SettingLoaded(
      chartDetailCount: chartDetailCount ?? this.chartDetailCount,
      furnaces: furnaces ?? this.furnaces,
      matNumbers: matNumbers ?? this.matNumbers,
    );
  }
}

class SettingError extends SettingState {
  final String message;

  const SettingError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchLoading extends SettingState {}

class SearchSuccess extends SettingState {
  final Map<String, dynamic> data;
  const SearchSuccess(this.data);
}

class SearchError extends SettingState {
  final String message;
  const SearchError(this.message);
}

class FormDataState extends SettingState {
  final FormState formState;
  final List<Furnace>? furnaces;
  final List<CustomerProduct>? matNumbers;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  const FormDataState({
    required this.formState,
    this.furnaces,
    this.matNumbers,
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  FormDataState copyWith({
    FormState? formState,
    List<Furnace>? furnaces,
    List<CustomerProduct>? matNumbers,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
  }) {
    return FormDataState(
      formState: formState ?? this.formState,
      furnaces: furnaces ?? this.furnaces,
      matNumbers: matNumbers ?? this.matNumbers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}