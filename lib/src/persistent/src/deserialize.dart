import 'package:postgresql/postgresql.dart' show Row;
import '../../entity/application.dart';
import '../../entity/application_environment.dart';
import '../../entity/application_revision.dart';
import '../../entity/aws_cloudfront.dart';
import '../../entity/aws_s3.dart';
import '../../entity/session.dart';
import '../../entity/user.dart';
import '../../entity/uuid.dart';

Application deserializeToApplication(Row row) => new Application(id: row.id, name: row.name, ownerId: row.owner_id);

ApplicationEnvironment deserializeToApplicationEnvironment(Row row) =>
  new ApplicationEnvironment(
    id: row.id,
    name: row.name,
    bucketId: new Uuid.fromString(row.bucket_id),
    destinationId: new Uuid.fromString(row.destination_id),
  );

ApplicationRevision deserializeToApplicationRevision(Row row) =>
  new ApplicationRevision(id: row.id, createdAt: row.created_at);

AwsCloudfront deserializeToAwsCloudfront(Row row) =>
  new AwsCloudfront(
    id: new Uuid.fromString(row.id),
    distributionId: row.payload['distributionId'],
    arn: row.payload['arn'],
    domainName: row.payload['domainName'],
  );

AwsS3 deserializeToAwsS3(Row row) =>
  new AwsS3(
    id: new Uuid.fromString(row.id),
    bucketName: row.payload['bucketName'],
  );

Session deserializeToSession(Row row) => row == null ? null : new Session.fromToken(row.token);

User deserializeToUser(Row row) =>
  new User(
    id: row.id,
    username: row.username,
    email: row.email,
    name: row.name,
    profileImageUrl: row.profile_image_url,
  );