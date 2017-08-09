import 'package:matcher/matcher.dart';
export 'package:matcher/matcher.dart';

final RegExp _emailRegExp = new RegExp(r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$");
final RegExp _urlRegExp = new RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');
final RegExp _uuidRegExp = new RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');

class ValidationException implements Exception {
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

Matcher isString = const isInstanceOf<String>();

Matcher isValidString = allOf(isString, isNotNull, isNotEmpty);

Matcher isEmail = predicate(
  (dynamic value) => value is String && _emailRegExp.hasMatch(value),
  'a valid e-mail',
);

Matcher isUrl = predicate(
  (dynamic value) => value is String && _urlRegExp.hasMatch(value),
  'a valid URL',
);

Matcher isUuid = predicate(
  (dynamic value) => value is String && _urlRegExp.hasMatch(value),
  'a valid UUID',
);
