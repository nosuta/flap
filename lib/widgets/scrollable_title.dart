import 'package:flutter/material.dart';

class ScrollableTitle extends StatefulWidget {
  const ScrollableTitle({super.key, required this.title, this.onTap});

  final String title;
  final void Function()? onTap;

  @override
  State<ScrollableTitle> createState() => _ScrollableTitleState();
}

class _ScrollableTitleState extends State<ScrollableTitle> {
  final scrollController = ScrollController();
  bool onLeftEdge = true;
  bool onRightEdge = false;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _scrollListener();
    });
  }

  void _scrollListener() {
    if (scrollController.offset <= 0) {
      setState(() {
        onLeftEdge = true;
      });
    } else {
      setState(() {
        onLeftEdge = false;
      });
    }

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      setState(() {
        onRightEdge = true;
      });
    } else {
      setState(() {
        onRightEdge = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            onLeftEdge ? Colors.white : Colors.transparent,
            Colors.white,
            Colors.white,
            onRightEdge ? Colors.white : Colors.transparent,
          ],
          stops: [0.0, 0.25, 0.75, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: TextButton(
        onPressed: widget.onTap,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Text(widget.title, maxLines: 1, softWrap: false),
        ),
      ),
    );
  }
}
