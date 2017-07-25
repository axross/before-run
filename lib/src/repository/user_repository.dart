import 'dart:async';
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Row;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';

User _assembleUser(Row row) =>
  new User(id: row.id, username: row.username, email: row.email, name: row.name, profileImageUrl: row.profile_image_url);

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

class UserRepository {
  final Pool _postgresConnectionPool;

  Future<User> getUser(int userId) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final row = await connection.query('select id, username, email, name, profile_image_url from users where id = @id limit 1;').single;

      return _assembleUser(row);
    } finally {
      connection.close();
    }
  }

  Future<User> createOrUpdate(User user) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      await connection.execute(
        'insert into users (id, username, email, name, profile_image_url, created_at, updated_at) values (@id, @username, @email, @name, @profileImageUrl, @now, @now) on conflict (id) do update set username = @username, email = @email, name = @name, profile_image_url = @profileImageUrl, updated_at = @now;',
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

      return _assembleUser(row);
    } finally {
      connection.close();
    }
  }

  Future<User> getUserBySession(Session session) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query(
        'select users.id as id, username, email, name, profile_image_url from sessions inner join users on sessions.user_id = users.id where sessions.token = @token limit 1;',
        {
          'token': session.token,
        },
      ).toList();

      if (rows.length != 1) {
        throw new UserNotFoundException(token: session.token);
      }

      return _assembleUser(rows.first);
    } finally {
      connection.close();
    }
  }

  UserRepository({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
