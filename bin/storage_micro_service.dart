import 'dart:io';

import 'package:dart_flux/dart_flux.dart';
import 'package:storage_micro_service/handler.dart';

void main(List<String> arguments) async {
  Router router = Router()
      .handler(AppHandlers.uploadHandler)
      .handler(AppHandlers.downloadHandler);
  Server server = Server(
    InternetAddress.anyIPv4,
    6000,
    router,
    upperMiddlewares: [Middleware(null, null, corsByPassing)],
  );
  await server.run();
}
