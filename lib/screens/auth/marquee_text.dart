import 'package:material_ui/material_ui.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double gap;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.gap = 24,
    this.scrollDuration = const Duration(seconds: 10),
    this.pauseDuration = const Duration(seconds: 30),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late AnimationController _animController;

  double _textWidth = 0;
  double _boxWidth = 0;
  bool _running = false;

  bool get _shouldScroll => _textWidth > _boxWidth;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: widget.scrollDuration,
    );

    _animController.addListener(() {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(
        _animController.value * (_textWidth + widget.gap),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _measureText() {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = painter.width;
  }

  Future<void> _startCycle() async {
    if (_running || !_shouldScroll) return;
    _running = true;

    while (mounted && _shouldScroll) {
      await _animController.forward(from: 0);

      await Future.delayed(widget.pauseDuration);

      _scrollController.jumpTo(0);
    }

    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    _measureText();

    return LayoutBuilder(
      builder: (context, constraints) {
        _boxWidth = constraints.maxWidth;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startCycle();
        });

        return ClipRect(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                Text(widget.text, style: widget.style, softWrap: false),
                if (_shouldScroll) SizedBox(width: widget.gap),
                if (_shouldScroll)
                  Text(widget.text, style: widget.style, softWrap: false),
              ],
            ),
          ),
        );
      },
    );
  }
}
