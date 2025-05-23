import 'dart:io';

import 'package:dart_flux/dart_flux.dart';
import 'package:storage_micro_service/handler.dart';

void main(List<String> arguments) async {
  Router router =
      Router()
        ..middleware(corsByPassing)
            .handler(AppHandlers.uploadHandler)
            .handler(AppHandlers.downloadHandler);
  Server server = Server(InternetAddress.anyIPv4, 4001, router);
  await server.run();
}
