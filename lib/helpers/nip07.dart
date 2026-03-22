import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;
import 'package:logging/logging.dart';


class Nip07 {
  static Future<String?> getPublicKey() async {
    final log = Logger('Nip07 getPublicKey');
    final nostr = web.window.getProperty('nostr'.toJS).jsify() as JSObject;
    if (nostr.isUndefinedOrNull) {
      log.warning('nostr browser extension is not installed');
      return null;
    }
    final getPublicKey = nostr
        .callMethod<JSPromise<JSString>>('getPublicKey'.toJS)
        .toDart;
    try {
      final pkjs = await getPublicKey;
      final pkdart = pkjs.toDart;
      log.fine('getPublicKey: $pkdart');
      return pkdart;
    } catch (e) {
      log.warning('getPublicKey failed: $e');
    }
    return null;
  }

  static Future<String?> signEvent(String eventJson) async {
    final log = Logger('Nip07 signEvent');
    final nostr = web.window.getProperty('nostr'.toJS).jsify() as JSObject;
    if (nostr.isUndefinedOrNull) {
      log.warning('nostr browser extension is not installed');
      return null;
    }
    // JSON string → JS Object
    final jsEvent = _jsonParse(eventJson);
    try {
      // signEvent(jsObject) → Promise<JSObject>
      final signedJs = await nostr
          .callMethod<JSPromise<JSObject>>('signEvent'.toJS, jsEvent)
          .toDart;
      // JS Object → JSON string
      final result = _jsonStringify(signedJs);
      log.fine('signed event: $result');
      return result;
    } catch (e) {
      log.warning('signEvent failed: $e');
    }
    return null;
  }

  static JSObject _jsonParse(String json) {
    final jsonObj = web.window.getProperty('JSON'.toJS) as JSObject;
    return jsonObj.callMethod<JSObject>('parse'.toJS, json.toJS);
  }

  static String _jsonStringify(JSObject obj) {
    final jsonObj = web.window.getProperty('JSON'.toJS) as JSObject;
    return (jsonObj.callMethod<JSString>('stringify'.toJS, obj)).toDart;
  }

  // Future<List<String>?> _getSharedPublicKeysFromExtension() async {
  //   final nostr = web.window.getProperty('nostr'.toJS).jsify() as JSObject;
  //   if (nostr.isUndefinedOrNull) {
  //     log.warning('nostr browser extension is not installed');
  //     return null;
  //   }
  //   final getSharedPublicKeys = nostr
  //       .callMethod<JSPromise<JSArray<JSString>>>('getSharedPublicKeys'.toJS)
  //       .toDart;
  //   try {
  //     final pubkeysJS = await getSharedPublicKeys;
  //     final keys = pubkeysJS.toDart;
  //     List<String> pubkeys = [];
  //     for (var key in keys) {
  //       final pubkey = key.toDart;
  //       if (pubkey.isNotEmpty) {
  //         pubkeys.add(pubkey);
  //       }
  //     }
  //     return pubkeys;
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
