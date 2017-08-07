import '../../entity/application.dart';
import '../../entity/application_environment.dart';
import '../../entity/application_revision.dart';
import '../../entity/user.dart';

Map<String, dynamic> serializeApplication(Application application) => {
  'id': application.id,
  'name': application.name,
};

Map<String, dynamic> serializeApplicationEnvironment(ApplicationEnvironment environment) => {
  'id': environment.id,
  'name': environment.name,
  'bucketId': environment.bucketId,
  'destinationId': environment.destinationId,
};

Map<String, dynamic> serializeApplicationRevision(ApplicationRevision revision) => {
  'id': revision.id,
  'createdAt': revision.createdAt.toIso8601String(),
};

Map<String, dynamic> serializeUser(User user) => {
  'id': user.id,
  'username': user.username,
  'email': user.email,
  'name': user.name,
  'profileImageUrl': user.profileImageUrl,
};
