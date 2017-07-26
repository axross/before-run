import 'package:postgresql/postgresql.dart' show Row;
import '../../entity/application.dart';
import '../../entity/application_environment.dart';
import '../../entity/session.dart';
import '../../entity/user.dart';

Application deserializeToApplication(Row row) => new Application(id: row.id, name: row.name);

ApplicationEnvironment deserializeToApplicationEnvironment(Row row) =>
  new ApplicationEnvironment(id: row.id, name: row.name);

Session deserializeToSession(Row row) => row == null ? null : new Session.fromToken(row.token);

User deserializeToUser(Row row) =>
  new User(
    id: row.id,
    username: row.username,
    email: row.email,
    name: row.name,
    profileImageUrl: row.profile_image_url,
  );