import 'package:http/http.dart' as http;

http.Client createProxymanProxyHttpClient(
  String proxyDirective,
) => throw UnsupportedError(
  'USE_PROXY requires dart:io. Configure the proxy in the browser or OS instead.',
);
