import 'dart:async';
import 'dart:io';

import 'package:dart_flux/core/server/routing/interface/http_entity.dart';
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

FutureOr<HttpEntity> corsByPassing(request, response, pathArgs) async {
  var method = request.request.method;

  // Extract requested headers from the OPTIONS preflight request
  var requestedHeaders =
      request.request.headers[HttpHeaders.accessControlRequestHeadersHeader];

  // Add CORS headers
  request.response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
    ..set(HttpHeaders.accessControlAllowHeadersHeader, '*')
    ..set(
      HttpHeaders.accessControlAllowMethodsHeader,
      'GET, POST, PUT, DELETE, PATCH, OPTIONS',
    );

  // Allow the requested headers from the preflight request
  if (requestedHeaders != null) {
    request.response.headers.set(
      HttpHeaders.accessControlAllowHeadersHeader,
      requestedHeaders.join(', '),
    );
  } else {
    // If no specific headers were requested, allow all common headers
    request.response.headers.set(
      HttpHeaders.accessControlAllowHeadersHeader,
      '*',
    );
  }

  if (method == 'OPTIONS') {
    request.request.response.statusCode = HttpStatus.noContent;
    await response.close();
    return response;
  }

  return request;
}
