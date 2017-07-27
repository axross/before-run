import 'package:meta/meta.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String name;
  final String profileImageUrl;

  User({
    @required this.id, 
    @required this.username, 
    @required this.email, 
    @required this.name, 
    @required this.profileImageUrl,
  });
}
