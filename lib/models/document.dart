import '../source.dart';

part 'document.freezed.dart';

enum DocumentType { sales, purchases, expenses, writeOffs }

@freezed
class Document with _$Document {
  const Document._();

  const factory Document.sales(DocumentForm form, List<Sales> salesList) = _Sales;
  const factory Document.purchases(DocumentForm form, List<Purchases> purchaseList) = _Purchases;
  const factory Document.expenses(DocumentForm form, List<Expense> expenseList) = _Expenses;
  const factory Document.writeOffs(DocumentForm form) = _WriteOffs;

  factory Document.empty() => const Document.sales(DocumentForm(), <Sales>[]);

  Map<String, dynamic> toJson(DocumentType documentType) {
    final jsonDocument = form.convertToJson();
    final details = _getDetails(documentType);
    jsonDocument['details'] = details.map((e) => e.convertToJson()).toList();
    return jsonDocument;
  }

  List _getDetails(DocumentType documentType) {
    switch (documentType) {
      case DocumentType.sales:
        return maybeWhen(
            sales: (_, salesList) => salesList, orElse: () => <Sales>[]);
      case DocumentType.purchases:
        return maybeWhen(
            purchases: (_, purchaseList) => purchaseList,
            orElse: () => <Purchases>[]);
      case DocumentType.expenses:
        return maybeWhen(
            expenses: (_, expenseList) => expenseList,
            orElse: () => <Expense>[]);
      case DocumentType.writeOffs:
        return maybeWhen(sales: (_, sales) => sales, orElse: () => []);
    }
  }
}
