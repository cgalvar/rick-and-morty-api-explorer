import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:soriana_character_explorer/core/di/injection.dart';
import 'package:soriana_character_explorer/core/network/proxyman_forward_proxy.dart';

class _TestCoreModule extends CoreModule {}

void main() {
  test('builds the exact Proxyman forward proxy directive', () {
    expect(
      proxymanProxyDirective(host: 'proxy.example.test', port: 9099),
      'PROXY proxy.example.test:9099',
    );
  });

  test('requires a proxy host when enabled', () {
    expect(
      () => proxymanProxyDirective(host: '', port: 9099),
      throwsA(isA<StateError>()),
    );
  });

  test('requires a proxy port between 1 and 65535', () {
    expect(
      () => proxymanProxyDirective(host: 'proxy.example.test', port: 0),
      throwsA(isA<StateError>()),
    );
    expect(
      () => proxymanProxyDirective(host: 'proxy.example.test', port: 65536),
      throwsA(isA<StateError>()),
    );
  });

  test('selects a native proxy transport only when USE_PROXY is enabled', () {
    final httpClient = configuredProxymanHttpClient();
    addTearDown(() => httpClient?.close());

    if (useProxymanProxy) {
      expect(httpClient, isA<IOClient>());
    } else {
      expect(httpClient, isNull);
    }
  });

  test('does not require proxy defines when the proxy is disabled', () {
    if (!useProxymanProxy) {
      expect(configuredProxymanHttpClient(), isNull);
    }
  });

  test('keeps the official API base URL and adds no interceptor', () {
    final client = _TestCoreModule().chopperClient;
    addTearDown(client.dispose);

    expect(client.baseUrl, Uri.parse('https://rickandmortyapi.com/api'));
    expect(client.interceptors, isEmpty);
  });
}
