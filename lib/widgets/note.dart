import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logging/logging.dart';
import 'package:fixnum/fixnum.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hexpattern/hexpattern.dart';

class Note extends StatelessWidget {
  Note({
    required this.nevent,
    required this.pubkey,
    required this.npub,
    required this.lang,
    required this.subject,
    required this.content,
    required this.createdAt,
    required this.name,
    required this.picture,
    super.key,
  }) : assert(pubkey.length == 64),
       _createdAtDate = DateTime.fromMillisecondsSinceEpoch(
         (createdAt * 1000).toInt(),
       ),
       _shortPubkey = npub.substring(5, 12),
       _contentOneLine = LineSplitter().convert(content.trimLeft())[0];

  final String nevent;
  final String pubkey;
  final String lang;
  final String npub;
  final String subject;
  final String content;
  final Int64 createdAt;
  final String? name;
  final String? picture;
  final log = Logger('Note');

  final DateTime _createdAtDate;
  final String _shortPubkey;
  final String _contentOneLine;

  Widget _iconPlaceholder(BuildContext context) {
    if (pubkey.isEmpty) {
      return CircleAvatar(radius: 7.5);
    }
    return HexPattern(
      hexKey: pubkey,
      height: 15,
      start: Theme.of(context).colorScheme.onSurface,
      end: Theme.of(context).colorScheme.onSurface,
      strokeWeight: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              // TODO: media preview
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (picture != null && picture!.isNotEmpty)
                          CachedNetworkImage(
                            width: 15,
                            height: 15,
                            fit: BoxFit.contain,
                            fadeInDuration: Duration(milliseconds: 250),
                            fadeOutDuration: Duration(milliseconds: 250),
                            placeholder: (context, url) {
                              return _iconPlaceholder(context);
                            },
                            errorWidget: (context, url, error) {
                              return _iconPlaceholder(context);
                            },
                            imageUrl: picture!,
                            imageBuilder: (context, imageProvider) {
                              return CircleAvatar(
                                backgroundImage: imageProvider,
                              );
                            },
                          ),
                        if (picture == null) _iconPlaceholder(context),
                        SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: name != null
                              ? Text(
                                  name!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _shortPubkey,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        // if (profile != null) Text(profile!.dnsId),
                        SizedBox(width: 8),
                        Text(
                          timeago.format(_createdAtDate, locale: 'en_short'),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '($lang)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            subject.isNotEmpty ? subject : _contentOneLine,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              fontWeight: subject.isNotEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
