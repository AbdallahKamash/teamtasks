import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/marquee_text.dart';

class WorkspaceSwapper extends ConsumerStatefulWidget {
  const WorkspaceSwapper({super.key});

  @override
  ConsumerState<WorkspaceSwapper> createState() => _WorkspaceButtonState();
}

List<String> workspaces = ["sdfsd"];

class _WorkspaceButtonState extends ConsumerState<WorkspaceSwapper>
    with TickerProviderStateMixin {
  bool _expanded = false;
  String chosen = workspaces.isNotEmpty ? workspaces.first : "";

  // LayerLink connects the button to the floating dropdown
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
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
    setState(() => _expanded = true && workspaces.isNotEmpty);
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
          offset: Offset(0, size.height), // Starts exactly below the button
          child: Material(
            color: Colors.transparent,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              axisAlignment: -1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                  )
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8,),
                    for (final workspace in workspaces)
                      workspaceItem(workspace),
                    if (workspaces.length > 1) Divider(height: 0, color: Colors.grey.shade300,),
                    if (workspaces.length > 1) SizedBox(height: 8,),
                    addWorkspace(),
                    SizedBox(height: 8,),
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
    // CompositedTransformTarget ensures the overlay follows this specific widget
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          constraints: BoxConstraints(
          ),
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            // Use a uniform border for both states to satisfy the BorderRadius requirement
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: _expanded
                ? const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            )
                : BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: workspaces.isNotEmpty ? Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 20, width: 20,
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
              SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? -0.25 : 0,
                duration: const Duration(milliseconds: 100),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              ),
            ],
          ) : addWorkspace(),
        ),
      ),
    );
  }

  Widget workspaceItem(String text) {
    if (text == chosen) return const SizedBox.shrink();
    return InkWell(
      onTap: () {
        setState(() => chosen = text);
        _closeDropdown();
      },
      child: Directionality(
        textDirection: .rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8,0,8,8),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 20, width: 20,
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

  Widget addWorkspace() {
    return InkWell(
      onTap: () {
        _closeDropdown();
      },
      child: Directionality(
        textDirection: .rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(workspaces.isNotEmpty ? 8 : 0,0,8,0),
          child: Row(
            children: [
              Expanded(
                child: MarqueeText(
                  text: 'إضافة مساحة عمل جديدة',
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(child: Icon(Icons.add_rounded, size: 20,)),
            ],
          ),
        ),
      ),
    );
  }
}