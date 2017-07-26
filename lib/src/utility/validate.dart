import 'package:matcher/matcher.dart';
import '../request_exception.dart';

export 'package:matcher/matcher.dart';

final RegExp _emailRegExp = new RegExp(
    r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$");
final RegExp _urlRegExp = new RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

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

Matcher isEmail = predicate(
  (dynamic value) => value is String && _emailRegExp.hasMatch(value),
  'a valid e-mail',
);

Matcher isUrl = predicate(
  (dynamic value) => value is String && _urlRegExp.hasMatch(value),
  'a valid e-mail',
);
