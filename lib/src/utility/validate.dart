import 'package:matcher/matcher.dart';
import '../exception/bad_request_exception.dart';

export 'package:matcher/matcher.dart';

class ValidationException implements BadRequestException {
  final String message;

  String toString() => message;

  ValidationException(this.message);
}

void validate(dynamic input, Matcher matcher, {String key = 'value'}) {
  final isMatched = matcher.matches(input, {});

  if (!isMatched) {
    throw new ValidationException(matcher.describe(new StringDescription('$key must be: ')).toString());
  }

  return input;
}
