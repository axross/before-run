import 'dart:async' show Future, Stream;
import 'package:gcloud/storage.dart' show ObjectMetadata, Storage;
import 'package:googleapis_auth/auth_io.dart' show clientViaServiceAccount, ServiceAccountCredentials;
import 'package:http/http.dart' show Client;
import 'package:meta/meta.dart';
import '../entity/application_revision.dart';

class ApplicationRevisionFileStorage {
  final Storage _storage;

  Future<dynamic> saveRevisionFile(ApplicationRevision revision, Stream<List<int>> stream) =>
    stream
      .pipe(_storage
        .bucket('before-run-revisions')
        .write(
          '${revision.id}',
          metadata: new ObjectMetadata(
            cacheControl: 'private,max-age=${60 * 60 * 24}',
            contentEncoding: 'gzip',
            contentType: 'application/zip',
          ),
        ),
      );

  ApplicationRevisionFileStorage({@required Client client}):
    _storage = new Storage(client, 'before-run');

  static Future<ApplicationRevisionFileStorage> createStorage({@required String serviceAccountKeyJson, @required String projectName}) async {
    final client = await clientViaServiceAccount(new ServiceAccountCredentials.fromJson(serviceAccountKeyJson), Storage.SCOPES);

    return new ApplicationRevisionFileStorage(client: client);
  }
}
