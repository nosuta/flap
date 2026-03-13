// import 'dart:async';
// import 'dart:js_interop';
// import 'dart:js_interop_unsafe';

// import 'package:flutter/foundation.dart';
// import 'package:web/web.dart' as web;
// import 'package:logging/logging.dart';

// import 'package:flap/pb/account.pb.dart' as pb;
// import 'package:flap/bridge/bridge.dart';
// import 'package:flap/vault/vault.dart';

// class Accounts extends ChangeNotifier {
//   static Accounts? _instance;
//   Accounts._() {
//     // TODO:
//   }
//   factory Accounts() {
//     _instance ??= Accounts._();
//     return _instance!;
//   }

//   String? pubkeyFromExtension = '';

//   final log = Logger('Account');
//   final vault = Vault();

//   Future<void> createAccount(pb.Account account) async {
//     if (!account.hasType()) {
//       throw Exception('account has no account type');
//     }
//     final list = await vault.get<pb.Accounts>('accounts');
//     final accounts = list?.accounts.toList();
//   }

//   Future<String?> _getPublicKeyFromExtension() async {
//     if (pubkeyFromExtension != null) {
//       return pubkeyFromExtension;
//     }
//     final nostr = web.window.getProperty('nostr'.toJS).jsify() as JSObject;
//     if (nostr.isUndefinedOrNull) {
//       log.warning('nostr browser extension is not installed');
//       return null;
//     }

//     try {
//       nostr.callMethod(
//         'on'.toJS,
//         'accountChanged'.toJS,
//         (() {
//           log.fine('accountChanged');
//           try {
//             final getPublicKey = nostr
//                 .callMethod<JSPromise<JSString>>('getPublicKey'.toJS)
//                 .toDart;
//             getPublicKey.then((pkjs) {
//               final pkdart = pkjs.toDart;
//               log.fine('getPublicKey on accountChanged: $pkdart');
//               pubkeyFromExtension = pkdart;
//               notifyListeners();
//             });
//           } catch (e) {
//             log.warning('getPublicKey failed: $e');
//           }
//         }).toJS,
//       );
//     } catch (e) {
//       log.warning('nostr.on() failed: $e');
//     }

//     final getPublicKey = nostr
//         .callMethod<JSPromise<JSString>>('getPublicKey'.toJS)
//         .toDart;
//     try {
//       final pkjs = await getPublicKey;
//       final pkdart = pkjs.toDart;
//       log.fine('getPublicKey: $pkdart');
//       return pkdart;
//     } catch (e) {
//       log.warning('getPublicKey failed: $e');
//     }
//     return null;
//   }

//   Future<List<String>?> _getSharedPublicKeysFromExtension() async {
//     final nostr = web.window.getProperty('nostr'.toJS).jsify() as JSObject;
//     if (nostr.isUndefinedOrNull) {
//       log.warning('nostr browser extension is not installed');
//       return null;
//     }
//     final getSharedPublicKeys = nostr
//         .callMethod<JSPromise<JSArray<JSString>>>('getSharedPublicKeys'.toJS)
//         .toDart;
//     try {
//       final pubkeysJS = await getSharedPublicKeys;
//       final keys = pubkeysJS.toDart;
//       List<String> pubkeys = [];
//       for (var key in keys) {
//         final pubkey = key.toDart;
//         if (pubkey.isNotEmpty) {
//           pubkeys.add(pubkey);
//         }
//       }
//       return pubkeys;
//     } catch (e) {
//       return null;
//     }
//   }
// }
