// ignore_for_file: avoid_print

import 'package:dart_wot/binding_http.dart';
import 'package:dart_wot/core.dart';

void main() async {
  final servient =
      Servient.create(servers: [HttpServer(HttpConfig(port: 3000))]);

  final wot = await servient.start();

  final exposedThing = await wot.produce({
    // FIXME: TD is not supplemented with missing fields
    '@context': 'https://www.w3.org/2022/wot/td/v1.1',
    'title': 'My Lamp Thing',
    'properties': {
      'status': {
        'type': 'string',
        'forms': [
          {
            'href': '/status',
          }
        ],
      },
    },
  });

  // await exposedThing.expose();
}
