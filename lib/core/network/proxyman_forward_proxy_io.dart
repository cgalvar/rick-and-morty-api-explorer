import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createProxymanProxyHttpClient(String proxyDirective) {
  final client = HttpClient()..findProxy = (_) => proxyDirective;

  if (kDebugMode) {
    client.badCertificateCallback = (_, _, _) => true;
  }

  return IOClient(client);
}
