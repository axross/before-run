import 'package:angel_validate/angel_validate.dart' as angel;
export 'package:angel_validate/angel_validate.dart';

class ValidationException implements Exception {
  final List<String> errorMessages;

  String toString() => errorMessages.join('\n');

  ValidationException(this.errorMessages);
}

class Validator {
  final angel.Validator _validator;
  
  T validate<T extends Map<dynamic, dynamic>>(T input) {
    final result = _validator.check(input);

    if (result.errors.length >= 1) {
      throw new ValidationException(result.errors);
    }

    return result.data;
  }

  Validator(Map<String, dynamic> schema):
    _validator = new angel.Validator(schema);
}
