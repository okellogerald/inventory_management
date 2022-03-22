import 'package:uuid/uuid.dart';

class Utils {
  static const _uuid = Uuid();

  static getRandomId() => _uuid.v4();

  static String convertToMoneyFormat(double number,
      [bool returnWithDecimals = true]) {
    final pieces = <String>[];
    String stringVersion = number.toString();
    final index = stringVersion.indexOf('.');
    final decimals = stringVersion.substring(index, stringVersion.length);
    final isNegative = stringVersion.startsWith('-');
    stringVersion = stringVersion.substring(isNegative ? 1 : 0, index);

    for (int i = 0; i < stringVersion.length / 3; i++) {
      final length = stringVersion.length;

      if (length > 3) {
        final added = stringVersion.substring(length - 3, length);
        pieces.add(added);
        stringVersion = stringVersion.substring(0, length - 3);
      }
    }

    pieces.add(stringVersion);

    if (pieces.length == 1) {
      return (isNegative ? '- ' : '') +
          pieces.first.toString() +
          (returnWithDecimals ? '.00' : '');
    }

    final reversedList = pieces.reversed.toList();
    String money = '';
    for (int i = 0; i < reversedList.length; i++) {
      final v = reversedList[i];
      money = i == reversedList.length - 1 ? money + v : money + v + ',';
    }

    return (isNegative ? '-' : '') +
        money +
        (returnWithDecimals
            ? (decimals.length == 2 ? '${decimals}0' : decimals)
            : '');
  }
}
