import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application_bucket.dart';
import '../entity/application_destination.dart';
import '../entity/application_environment.dart';
import '../entity/user.dart';
import '../persistent/application_bucket_datastore.dart';
import '../persistent/application_datastore.dart';
import '../persistent/application_destination_datastore.dart';
import '../persistent/application_environment_datastore.dart';
import '../persistent/aws_cloudfront_client.dart';
import '../persistent/aws_s3_client.dart';

export '../persistent/application_datastore.dart' show ApplicationForbiddenException, ApplicationNotFoundException;
export '../persistent/application_environment_datastore.dart' show
  ApplicationEnvironmentConflictException,
  ApplicationEnvironmentNotFoundException,
  ApplicationEnvironmentForbiddenException;

class ApplicationEnvironmentUsecase {
  final ApplicationBucketDatastore _applicationBucketDatastore;
  final ApplicationDatastore _applicationDatastore;
  final ApplicationDestinationDatastore _applicationDestinationDatastore;
  final ApplicationEnvironmentDatastore _applicationEnvironmentDatastore;
  final AwsCloudfrontClient _awsCloudfrontClient;
  final AwsS3Client _awsS3Client;
  final Pool _postgresqlConnectionPool;

  Future<ApplicationEnvironment> getById({
    @required int applicationEnvironmentId,
    @required int applicationId,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      final application = await _applicationDatastore.getById(connection, id: applicationId, requester: requester);

      return await _applicationEnvironmentDatastore.getById(
        connection,
        id: applicationEnvironmentId,
        application: application,
        requester: requester,
      );
    } finally {
      connection.close();
    }
  }

  Future<Iterable<ApplicationEnvironment>> getAllByApplicationId({
    @required int applicationId,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      final application = await _applicationDatastore.getById(connection, id: applicationId, requester: requester);

      return await _applicationEnvironmentDatastore.getAllOfApplication(connection, application: application);
    } finally {
      connection.close();
    }
  }

  Future<ApplicationEnvironment> create({
    @required int applicationId,
    @required String name,
    @required ApplicationBucketType bucketType,
    @required String bucketName,
    @required String bucketRegion,
    @required String bucketAccessKeyId,
    @required String bucketSecretAccessKey,
    @required ApplicationDestinationType destinationType,
    @required String destinationDistributionId,
    @required String destinationAccessKeyId,
    @required String destinationSecretAccessKey,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      final application = await _applicationDatastore.getById(
        connection,
        id: applicationId,
        requester: requester,
      );

      // check
      await _awsS3Client.getAllObjectsOfBucket(
        bucketName: bucketName,
        region: bucketRegion,
        accessKeyId: bucketAccessKeyId,
        secretAccessKey: bucketSecretAccessKey,
      );

      // check
      final distribution = await _awsCloudfrontClient.getDistribution(
        distributionId: destinationDistributionId,
        accessKeyId: destinationAccessKeyId,
        secretAccessKey: destinationSecretAccessKey,
      );

      ApplicationEnvironment environment;

      await connection.runInTransaction(() async {
        final bucket = await _applicationBucketDatastore.createAwsS3(
          connection,
          bucketName: bucketName,
          accessKeyId: bucketAccessKeyId,
          secretAccessKey: bucketSecretAccessKey,
        );

        final destination = await _applicationDestinationDatastore.createAwsCloudfront(
          connection,
          distributionId: destinationDistributionId,
          arn: distribution.arn,
          domainName: distribution.domainName,
          accessKeyId: destinationAccessKeyId,
          secretAccessKey: destinationSecretAccessKey,
        );

        environment = await _applicationEnvironmentDatastore.create(
          connection,
          application: application,
          name: name,
          bucket: bucket,
          destination: destination,
          requester: requester,
        );
      });

      return environment;
    } finally {
      connection.close();
    }
  }

  ApplicationEnvironmentUsecase({
    @required ApplicationBucketDatastore applicationBucketDatastore,
    @required ApplicationDatastore applicationDatastore,
    @required ApplicationDestinationDatastore applicationDestinationDatastore,
    @required ApplicationEnvironmentDatastore applicationEnvironmentDatastore,
    @required AwsCloudfrontClient awsCloudfrontClient,
    @required AwsS3Client awsS3Client,
    @required Pool postgresqlConnectionPool,
  }):
    _applicationBucketDatastore = applicationBucketDatastore,
    _applicationDatastore = applicationDatastore,
    _applicationDestinationDatastore = applicationDestinationDatastore,
    _applicationEnvironmentDatastore = applicationEnvironmentDatastore,
    _awsCloudfrontClient = awsCloudfrontClient,
    _awsS3Client = awsS3Client,
    _postgresqlConnectionPool = postgresqlConnectionPool;
}