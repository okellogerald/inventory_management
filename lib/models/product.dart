import '../source.dart';

class Product {
  final String id, name, unit, categoryId;
  final double unitPrice, stockQuantity, stockValue;
  final String? code;

  const Product(
      {this.id = '',
      this.name = '',
      this.unit = '',
      this.unitPrice = 0.0,
      this.stockQuantity = 0.0,
      this.stockValue = 0.0,
      this.categoryId = '',
      this.code});

  String get getUnitPrice => Utils.convertToMoneyFormat(unitPrice);

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        unit: json['unit'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        stockQuantity: (json['stockQuantity'] as num).toDouble(),
        stockValue: (json['stockValue'] as num).toDouble(),
        categoryId: json['categoryId'] ?? '',
        code: json['code'],
      );

  factory Product.fromInventoryMovementJson(Map<String, dynamic> json) =>
      Product(
        id: json['Product.id'],
        name: json['Product.name'],
        unit: json['Product.unit'],
        stockQuantity: (json['InventoryMovement.quantity'] as num).toDouble(),
        stockValue: (json['InventoryMovement.totalValue'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() {
    String? _code;
    if (code != null) {
      //code can be '', that is empty and empty faces validation errors
      //from the server
      if (code!.isNotEmpty) _code = code!;
    }
    return {
      'name': name,
      'unit': unit,
      'unitPrice': unitPrice,
      'code': _code,
      'categoryId': categoryId
    };
  }

  Product copyWith(
      {String? unit,
      String? name,
      String? code,
      String? categoryId,
      double? unitPrice}) {
    return Product(
        id: id,
        code: code ?? this.code,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        categoryId: categoryId ?? this.categoryId);
  }
}
