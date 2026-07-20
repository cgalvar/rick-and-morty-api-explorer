import 'package:http/http.dart' as http;

import 'proxyman_forward_proxy_platform.dart';

const bool useProxymanProxy = bool.fromEnvironment('USE_PROXY');
const String proxymanProxyHost = String.fromEnvironment('PROXY_HOST');
const int proxymanProxyPort = int.fromEnvironment('PROXY_PORT');

String proxymanProxyDirective({
  String host = proxymanProxyHost,
  int port = proxymanProxyPort,
}) {
  if (host.isEmpty) {
    throw StateError('USE_PROXY requires a non-empty PROXY_HOST.');
  }
  if (port < 1 || port > 65535) {
    throw StateError('USE_PROXY requires PROXY_PORT between 1 and 65535.');
  }

  return 'PROXY $host:$port';
}

http.Client? configuredProxymanHttpClient() => useProxymanProxy
    ? createProxymanProxyHttpClient(proxymanProxyDirective())
    : null;
