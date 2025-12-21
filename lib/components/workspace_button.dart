import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/marquee_text.dart';

class WorkspaceButton extends ConsumerStatefulWidget {
  const WorkspaceButton({super.key});

  @override
  ConsumerState<WorkspaceButton> createState() => _WorkspaceButtonState();
}

class _WorkspaceButtonState extends ConsumerState<WorkspaceButton>
    with TickerProviderStateMixin {
  bool _expanded = false;
  String chosen = 'Workspace';

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 250),
    vsync: this,
  );

  void _toggleDropdown() {
    if (_expanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
    setState(() => _expanded = true);
  }

  void _closeDropdown() async {
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _expanded = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            color: Colors.transparent,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              axisAlignment: -1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _item('Workspace 1'),
                    _item('Workspace'),
                    _item('سيبس سيب شيس يبل سي لب شسي بشس بس'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 30, width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.purple.shade100,
                ),
              ),
              Expanded(
                child: MarqueeText(
                  text: chosen,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? -0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(String text) {
    if (text == chosen) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        setState(() => chosen = text);
        _closeDropdown();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.purple.shade100,
                ),
              ),

              Expanded(
                child: MarqueeText(
                  text: text,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}