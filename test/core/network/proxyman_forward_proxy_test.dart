import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/core/di/injection.dart';
import 'package:soriana_character_explorer/core/network/proxyman_forward_proxy.dart';
import 'package:soriana_character_explorer/core/network/proxyman_forward_proxy_platform.dart';

class _TestCoreModule extends CoreModule {}

class _HttpClient extends Mock implements HttpClient {}

class _Certificate extends Mock implements X509Certificate {}

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

  test('trusts Proxyman certificates for every host in debug', () {
    final httpClient = _HttpClient();

    final client = HttpOverrides.runZoned(
      () => createProxymanProxyHttpClient('PROXY proxy.example.test:9099'),
      createHttpClient: (_) => httpClient,
    );
    addTearDown(client.close);

    final findProxy =
        verify(() => httpClient.findProxy = captureAny()).captured.single
            as String Function(Uri);
    expect(
      findProxy(Uri.parse('https://rickandmortyapi.com/api/character')),
      'PROXY proxy.example.test:9099',
    );

    final callback =
        verify(
              () => httpClient.badCertificateCallback = captureAny(),
            ).captured.single
            as BadCertificateCallback;
    final certificate = _Certificate();
    expect(callback(certificate, 'rickandmortyapi.com', 443), isTrue);
    expect(callback(certificate, 'evil.rickandmortyapi.com', 443), isTrue);
    expect(callback(certificate, 'rickandmortyapi.com.evil', 443), isTrue);
    expect(callback(certificate, 'example.com', 443), isTrue);
  });

  test('keeps the official API base URL and adds no interceptor', () {
    final client = _TestCoreModule().chopperClient;
    addTearDown(client.dispose);

    expect(client.baseUrl, Uri.parse('https://rickandmortyapi.com/api'));
    expect(client.interceptors, isEmpty);
  });
}
