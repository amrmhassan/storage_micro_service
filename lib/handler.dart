import 'dart:io';

import 'package:dart_flux/core/server/routing/models/http_method.dart';
import 'package:dart_flux/core/server/routing/repo/handler.dart';
import 'package:dart_id/dart_id.dart';

class AppHandlers {
  static Handler uploadHandler = Handler('/upload', HttpMethod.post, (
    request,
    response,
    pathArgs,
  ) async {
    var obj = await request.form(saveFolder: './temp', acceptFormFiles: true);
    var receivedFile = obj.getFile('file').first;
    try {
      var parent = obj.getField('parent').firstOrNull?.value as String?;
      var fileName = obj.getField('fileName').firstOrNull?.value as String?;
      if (parent == null || parent.isEmpty) {
        parent = null;
      }
      if (fileName == null || fileName.isEmpty) {
        fileName = null;
      }

      String receivedFileName = receivedFile.path.split('/').last;
      String fileExtension = receivedFileName.split('.').last;
      if (parent != null) {
        fileName = fileName ?? '${DartID().generate()}.$fileExtension';
        fileName = '$parent/$fileName';
      }
      String filePath = '${ServerConstants.uploadFolder}/$fileName';
      File file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(await receivedFile.readAsBytes());
      String path = file.path;
      path = path.split(ServerConstants.uploadFolder).last;
      await receivedFile.delete();
      return response.write(path, code: 200);
    } catch (e) {
      await receivedFile.delete();

      rethrow;
    }
  });
  static Handler downloadHandler = Handler('/*', HttpMethod.get, (
    request,
    response,
    pathArgs,
  ) async {
    var ref = pathArgs['*'];
    String filePath = '${ServerConstants.uploadFolder}/$ref';
    var file = File(filePath);
    if (!file.existsSync()) {
      return response.write('File not found', code: 404);
    }

    return response.file(file);
  });
}

class ServerConstants {
  static const String uploadFolder = './uploadedFiles';
}
