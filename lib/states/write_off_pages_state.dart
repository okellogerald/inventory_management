import '../source.dart';

part 'write_off_pages_state.freezed.dart';

@freezed
class WriteOffPagesState with _$WriteOffPagesState {
  const factory WriteOffPagesState.loading(WriteOffSupplements supplements) = _Loading;
  const factory WriteOffPagesState.content(WriteOffSupplements supplements) = _Content;
  const factory WriteOffPagesState.success(WriteOffSupplements supplements) = _Success;
  const factory WriteOffPagesState.failed(WriteOffSupplements supplements,
      {String? message, @Default(false) bool showOnPage}) = _Failed;

  factory WriteOffPagesState.initial() => WriteOffPagesState.content(WriteOffSupplements.empty());
}
