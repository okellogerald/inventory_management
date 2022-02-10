import '../source.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final double quantity;

  Item({
    required this.id,
    required this.title,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
  });

  factory Item.empty() => Item(
        title: '',
        id: '',
        unit: 'ea.',
        unitPrice: 0,
        quantity: 0,
      );

  String get getQuantityValue =>
      Utils.convertToMoneyFormat(quantity * unitPrice);

  String get getUnitPrice => Utils.convertToMoneyFormat(unitPrice);

  Item copyWith(
      {String? id,
      String? title,
      String? unit,
      double? unitPrice,
      double? quantity}) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
