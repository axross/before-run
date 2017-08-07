import 'dart:convert' show UTF8;
import 'dart:typed_data' show Uint8List;

final _padding = [
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
];

Uint8List stringTo256bitUint8List(String value) =>
  new Uint8List.fromList(
    (UTF8.encode(value).toList()
      ..addAll(_padding)
    ).sublist(0, 32),
  );
