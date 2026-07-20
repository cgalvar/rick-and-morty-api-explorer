import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createProxymanProxyHttpClient(String proxyDirective) =>
    IOClient(HttpClient()..findProxy = (_) => proxyDirective);
