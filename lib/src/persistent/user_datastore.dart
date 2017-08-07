import 'dart:async';
import 'package:postgresql/postgresql.dart' show Connection;
import '../entity/session.dart';
import '../entity/user.dart';
import './src/deserialize.dart';

class UserDatastore {
  Future<User> getUserBySession(Connection connection, Session session) async {
    final rows = await connection.query(
      'select users.id as id, username, email, name, profile_image_url from sessions inner join users on sessions.user_id = users.id where sessions.token = @token limit 1;',
      {
        'token': session.token,
      },
    ).toList();

    if (rows.isEmpty) {
      throw new UserNotFoundException(token: session.token);
    }

    return deserializeToUser(rows.single);
  }

  Future<User> createOrUpdate(Connection connection, User user) async {
    await connection.execute(
      'insert into users (id, username, email, name, profile_image_url, created_at) values (@id, @username, @email, @name, @profileImageUrl, @now) on conflict (id) do update set username = @username, email = @email, name = @name, profile_image_url = @profileImageUrl, updated_at = @now;',
      {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'name': user.name,
        'profileImageUrl': user.profileImageUrl,
        'now': new DateTime.now(),
      },
    );

    final row = await connection.query('select id, username, email, name, profile_image_url from users where id = @id limit 1;').single;

    return deserializeToUser(row);
  }
}

class UserNotFoundException implements Exception {
  final int id;
  final String token;

  String toString() => id != null
    ? 'An user (id: "$id") is not found.'
    : 'An user (authentication token: "$token") is not found.';
  
  UserNotFoundException({this.id, this.token}) {
    assert(id != null || token != null);
  }
}
