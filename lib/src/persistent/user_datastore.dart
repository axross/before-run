import 'dart:async';
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';
import './src/deserialize.dart';
import './src/resource_exception.dart';

class UserDatastore {
  final Pool _postgresConnectionPool;

  // Future<User> getUser(int userId) async {
  //   final connection = await _postgresConnectionPool.connect();

  //   try {
  //     final row = await connection.query('select id, username, email, name, profile_image_url from users where id = @id limit 1;').single;

  //     return deserializeToUser(row);
  //   } finally {
  //     connection.close();
  //   }
  // }

  Future<User> getUserBySession(Session session) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query(
        'select users.id as id, username, email, name, profile_image_url from sessions inner join users on sessions.user_id = users.id where sessions.token = @token limit 1;',
        {
          'token': session.token,
        },
      ).toList();

      if (rows.isEmpty) {
        throw new UserNotFoundException(token: session.token);
      }

      return deserializeToUser(rows.first);
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

      return deserializeToUser(row);
    } finally {
      connection.close();
    }
  }

  UserDatastore({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
