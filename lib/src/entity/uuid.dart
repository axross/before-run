import 'package:uuid/uuid.dart' as DartUuid;

class Uuid {
  final List<int> buffer;

  String toString() => new DartUuid.Uuid().unparse(buffer);
  String toJson() => toString();

  @override
  int get hashCode => buffer.fold(17, (int previous, int current) => 37 * previous + current);

  @override
  bool operator ==(Uuid uuid) => uuid.toString() == toString();

  Uuid.v4():
    buffer = new DartUuid.Uuid().v4(buffer: new List(16));

  Uuid.v5(String value):
    buffer = new DartUuid.Uuid().v5(DartUuid.Uuid.NAMESPACE_NIL, value, buffer: new List(16));

  Uuid.fromString(String string):
    buffer = new DartUuid.Uuid().parse(string);
}
