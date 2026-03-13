import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:statescope/statescope.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:translator/translator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hexpattern/hexpattern.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:flap/bridge/bridge.dart';
import 'package:flap/pb/nostr.pb.dart' as pbnostr;
import 'package:flap/pb/message.pb.dart' as pbmessage;
import 'package:flap/widgets/slivers/progress_indicator_header.dart';
import 'package:flap/widgets/note.dart';
import 'package:flap/widgets/scrollable_title.dart';
import 'package:flap/pb/echo.connect.dart';
import 'package:flap/pb/echo.pb.dart' as pbecho;
import 'package:flap/pb/nostr.connect.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _log = Logger('HomeState');
  final _scrollController = ScrollController();
  final _titleScrollController = ScrollController();
  final _translator = GoogleTranslator();
  final _sliverStableListKey = GlobalKey();
  final _contextMenuController = ContextMenuController();
  final _focusNode = FocusNode();

  bool _loadingTop = false;
  bool _pullingTop = false;
  bool _guideTop = false;
  bool _loadingBottom = false;
  bool _appBarIsVisible = true;
  Map<String, pbnostr.Note> _notes = {};
  Int64 _latest = Int64(
    (DateTime.now().millisecondsSinceEpoch * 0.001).toInt(),
  );
  Int64 _oldest = Int64(-1);
  StreamSubscription<pbnostr.Note>? _topSubscription;
  StreamSubscription<pbnostr.Note>? _bottomSubscription;
  StreamSubscription<pbmessage.Push>? _pushSubscription;
  String? _preferredLanguage;
  String _connectResult = '';

  String _topic = 'nostr';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenScroll);
    unawaited(_subscribePush());
    unawaited(_fetchOldNotes());
    unawaited(_getLanguage());
  }

  @override
  void dispose() {
    _topSubscription?.cancel();
    _bottomSubscription?.cancel();
    _pushSubscription?.cancel();
    _titleScrollController.dispose();
    _scrollController.dispose();
    _contextMenuController.remove();
    _focusNode.dispose();
    super.dispose();
  }

  void _listenScroll() {
    switch (_scrollController.position.userScrollDirection) {
      case ScrollDirection.idle:
        break;
      case ScrollDirection.forward:
        if (!_appBarIsVisible) {
          _appBarIsVisible = true;
          setState(() {});
        }
        break;
      case ScrollDirection.reverse:
        if (_appBarIsVisible) {
          _appBarIsVisible = false;
          setState(() {});
        }
        break;
    }
    if (_scrollController.offset <= 0) {
      _guideTop = false;
      setState(() {});
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            ((15 + 15 + 32) * 8 + 15)) {
      unawaited(_fetchOldNotes());
    }
  }

  Future<void> _getLanguage() async {
    final languages = await Devicelocale.preferredLanguages;
    _preferredLanguage = languages?.first.toString().substring(0, 2);
    _log.fine('lang: $_preferredLanguage');
  }

  Future<void> _onTapTitle() async {
    if (!context.mounted) {
      return;
    }
    final offset = _scrollController.offset;
    if (offset == 0) {
      await _fetchNewNotes();
      return;
    }

    final limit = MediaQuery.of(context).size.height;
    if (limit >= offset) {
      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCirc,
      );
    } else {
      _scrollController.jumpTo(limit);
      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCirc,
      );
    }
  }

  Future<void> _translateNote(String eventId) async {
    if (_preferredLanguage == null || _notes[eventId] == null) {
      return;
    }
    final n = _notes[eventId]!;
    if (n.lang != _preferredLanguage!) {
      try {
        final translated = await _translator.translate(
          n.content,
          from: n.lang,
          to: _preferredLanguage!,
        );
        n.translated = true;
        n.translatedContent = translated.text;
      } catch (e) {
        _log.fine('translate error: $e');
      }
    }
  }

  Future<void> _fetchNewNotes() async {
    final bridge = context.read<Bridge>();
    if (_loadingTop) {
      _pullingTop = false;
      setState(() {});
      return;
    }
    _log.info('fetch new notes');
    if (_topSubscription != null) {
      _log.info('fetch new notes: cancel subscription');
      _topSubscription!.cancel();
    }
    _loadingTop = true;
    _pullingTop = false;
    setState(() {});
    final now = Int64((DateTime.now().millisecondsSinceEpoch * 0.001).toInt());
    _log.info('fetch new notes: since $_latest until $now');
    final req = pbnostr.GetNotes(
      // topic: topic,
      range: pbnostr.TimeRange(since: _latest, until: now),
    );

    double offset = 0.0;

    final client = NostrServiceClient(bridge);
    final stream = client.fetchNotes(req);
    _topSubscription = stream.listen(
      (n) {
        if (n.id.isEmpty || n.pubkey.isEmpty || n.createdAt.isZero) {
          _log.info('invalid new note: $n');
          return;
        }
        if (_notes.containsKey(n.id)) {
          return;
        }
        _latest = now > n.createdAt ? n.createdAt : now;
        _notes = {n.id: n, ..._notes};
        offset += 15.0 + 15.0 + 32.0;
      },
      onDone: () {
        _loadingTop = false;
        if (offset > 0 && _scrollController.offset > 0) {
          _guideTop = true;
          final render =
              _sliverStableListKey.currentContext?.findRenderObject()
                  as RenderSuperSliverList?;
          render?.correctScrollOffset(offset);
        }
        setState(() {});
      },
      onError: (e) {
        _log.severe('fetch new notes error: $e');
        _loadingTop = false;
        setState(() {});
      },
    );
  }

  Future<void> _subscribePush() async {
    final bridge = context.read<Bridge>();
    _pushSubscription = bridge.push.listen((push) {
      if (context.mounted && push.hasNip05()) {
        final n = push.nip05;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('push test: ${n.id}')));
      }
    });
  }

  Future<void> _fetchOldNotes() async {
    if (_loadingBottom) {
      return;
    }
    final bridge = context.read<Bridge>();

    _log.info('fetch old notes');
    if (_bottomSubscription != null) {
      _log.info('fetch old notes: cancel subscription');
      _bottomSubscription!.cancel();
    }
    _loadingBottom = true;
    setState(() {});

    // since yesterday or yesterday of oldest
    final since = _oldest.isNegative
        ? Int64(
            (DateTime.now().add(Duration(days: -1)).millisecondsSinceEpoch *
                    0.001)
                .toInt(),
          )
        : Int64(
            (DateTime.fromMillisecondsSinceEpoch(
                      _oldest.toInt() * 1000,
                    ).add(Duration(days: -1)).millisecondsSinceEpoch *
                    0.001)
                .toInt(),
          );

    // until now or oldest
    final until = _oldest.isNegative
        ? Int64((DateTime.now().millisecondsSinceEpoch * 0.001).toInt())
        : _oldest;

    _log.info('fetch old notes: since $since until $_oldest');
    pbnostr.GetNotes req = pbnostr.GetNotes(
      topic: _topic,
      range: pbnostr.TimeRange(since: since, until: until),
    );

    final client = NostrServiceClient(bridge);
    final stream = client.fetchNotes(req);
    Map<String, pbnostr.Note> temp = {};
    _bottomSubscription = stream.listen(
      (n) {
        if (n.id.isEmpty || n.pubkey.isEmpty || n.createdAt.isZero) {
          _log.info('invalid old note: $n');
          return;
        }
        if (_notes.containsKey(n.id)) {
          return;
        }
        _oldest = since < n.createdAt ? since : n.createdAt;
        temp = {n.id: n, ...temp};
      },
      onDone: () {
        _notes = {..._notes, ...temp};
        _loadingBottom = false;
        setState(() {});
      },
      onError: (e) {
        _log.severe('fetch old notes error: $e');
        _loadingBottom = false;
        setState(() {});
      },
    );
  }

  double _calculateTextHeight(String text, double maxWidth, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.size.height;
  }

  Future<void> _testConnect() async {
    final bridge = context.read<Bridge>();
    final client = EchoServiceClient(bridge);

    setState(() {
      _connectResult = 'Calling Echo...';
    });

    try {
      final resp = await client.echo(
        pbecho.EchoRequest(message: 'Hello from Dart!'),
      );
      setState(() {
        _connectResult = 'Echo response: ${resp.message}\nStarting stream...';
      });

      await for (final streamResp in client.serverStream(
        pbecho.EchoRequest(message: 'Stream test'),
      )) {
        setState(() {
          _connectResult += '\n${streamResp.message}';
        });
      }
      setState(() {
        _connectResult += '\nDone!';
      });
    } catch (e) {
      setState(() {
        _connectResult = 'Error: $e';
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_connectResult),
          duration: Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bridge = context.watch<Bridge>();
    final theme = Theme.of(context);

    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (_contextMenuController.isShown &&
              event.physicalKey == PhysicalKeyboardKey.escape) {
            _contextMenuController.remove();
          }
        },
        child: SafeArea(
          child: RefreshIndicator.noSpinner(
            onStatusChange: (RefreshIndicatorStatus? status) {
              if (status == RefreshIndicatorStatus.armed) {
                setState(() {
                  _pullingTop = true;
                });
              }
            },
            onRefresh: _fetchNewNotes,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (_notes.isNotEmpty || !_loadingBottom)
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: ProgressIndicatorHeader(
                      loading: _loadingTop,
                      pulling: _pullingTop,
                      guide: _guideTop,
                    ),
                  ),
                SlidableAutoCloseBehavior(
                  child: SuperSliverList.builder(
                    key: _sliverStableListKey,
                    itemBuilder: (BuildContext context, int idx) {
                      if (idx == _notes.length) {
                        return SizedBox(
                          height: 500,
                          child: Skeletonizer(
                            child: ListView.builder(
                              itemBuilder: (context, idx) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: idx == 0 ? 15 : 0,
                                  ),
                                  child: Note(
                                    nevent:
                                        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
                                    pubkey:
                                        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
                                    lang: 'en',
                                    npub:
                                        'npub1lllllllllllllllllllllllllllllllllllllllllllllllllllsq7lrjw',
                                    subject: '',
                                    content: 'dummy',
                                    createdAt: Int64(0),
                                    name: null,
                                    picture: '',
                                  ),
                                );
                              },
                              itemCount: 8,
                            ),
                          ),
                        );
                      }
                      final n = _notes.entries.elementAt(idx);

                      return InkWell(
                        onTap: () {
                          if (_contextMenuController.isShown) {
                            _contextMenuController.remove();
                            return;
                          }
                          // TODO:
                        },
                        onSecondaryTapDown: (details) {
                          _contextMenuController.show(
                            context: context,
                            contextMenuBuilder: (context) {
                              return AdaptiveTextSelectionToolbar.buttonItems(
                                anchors: TextSelectionToolbarAnchors(
                                  primaryAnchor: details.globalPosition,
                                ),
                                buttonItems: [
                                  ContextMenuButtonItem(
                                    onPressed: () {
                                      _contextMenuController
                                          .remove(); // Dismiss the menu
                                    },
                                    label: 'Option 1',
                                  ),
                                  ContextMenuButtonItem(
                                    onPressed: () {
                                      _contextMenuController
                                          .remove(); // Dismiss the menu
                                    },
                                    label: 'Option 2',
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Placeholder();
                            },
                          );
                        },
                        child: Slidable(
                          key: ObjectKey(n.value.id),
                          endActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: ScrollMotion(),
                            // A pane can dismiss the Slidable.s
                            dismissible: DismissiblePane(onDismissed: () {}),
                            children: [
                              SlidableAction(
                                // An action can be bigger than the others.
                                onPressed: (ctx) {},
                                backgroundColor: Color.fromARGB(255, 200, 0, 0),
                                foregroundColor: Colors.white,
                                icon: Icons.report,
                                label: 'Report User',
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: idx == 0 ? 15 : 0),
                            child: Note(
                              nevent: n.value.nevent,
                              pubkey: n.value.pubkey,
                              lang: n.value.lang,
                              npub: n.value.npub,
                              subject: n.value.subject,
                              content: n.value.content,
                              createdAt: n.value.createdAt,
                              name: null,
                              picture: n.value.profile.picture.isEmpty
                                  ? null
                                  : n.value.profile.picture,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _notes.length + 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _appBarIsVisible ? 80.0 : 0,
        child: BottomAppBar(
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: SizedBox(
                      width: 40,
                      child: HexPattern(
                        hexKey:
                            'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
                        height: 15,
                        start: theme.colorScheme.onSurface,
                        end: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: _testConnect,
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.bolt, color: Colors.orange),
                ),
              ),
              Expanded(
                child: ScrollableTitle(
                  onTap: () {
                    if (bridge.ready) {
                      _onTapTitle();
                    }
                  },
                  // title: topic,
                  title: 'long-topic-test-too-long-to-display',
                ),
              ),
              IconButton(
                onPressed: bridge.ready
                    ? () async {
                        await _fetchNewNotes();
                      }
                    : null,
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.replay_outlined),
                ),
              ),
              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(Icons.tag),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // TODO: drawer
      // TODO: endDrawer
    );
  }
}

extension on Map<String, pbnostr.Note> {
  Map<String, pbnostr.Note> hasKeyPrefix(String prefix) {
    final matches = entries.where((ent) => ent.key.startsWith(prefix));
    return Map.fromEntries(matches);
  }
}
