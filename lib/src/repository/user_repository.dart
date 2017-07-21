import 'dart:async';
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Row;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';

User _assembleUser(Row row) =>
  new User(id: row.id, username: row.username, email: row.email, name: row.name, profileImageUrl: row.profile_image_url);

class UserRepository {
  final Pool _postgresConnectionPool;

  Future<User> getUser(int userId) async {
    final connection = await _postgresConnectionPool.connect();
    final row = await connection.query('select id, username, email, name, profile_image_url from users where id = @id limit 1;').single;

    connection.close();

    return _assembleUser(row);
  }

  Future<User> createOrUpdate(User user) async {
    final connection = await _postgresConnectionPool.connect();

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

    connection.close();

    return _assembleUser(row);
  }

  Future<User> getUserBySession(Session session) async {
    final connection = await _postgresConnectionPool.connect();

    final row = await connection.query('select users.id, username, email, name, profile_image_url from users join sessions on sessions.user_id = users.id where sessions.token = @token;', {
      'token': session.token,
    })
      .single;
    
    connection.close();

    return _assembleUser(row);
  }

  UserRepository({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
