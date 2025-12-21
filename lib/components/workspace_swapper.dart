import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import '../models/workspace_model.dart';
import '../screens/auth/marquee_text.dart';

class WorkspaceSwapper extends ConsumerStatefulWidget {
  const WorkspaceSwapper({super.key});

  @override
  ConsumerState<WorkspaceSwapper> createState() => _WorkspaceButtonState();
}

class _WorkspaceButtonState extends ConsumerState<WorkspaceSwapper>
    with TickerProviderStateMixin {
  bool _expanded = false;
  WorkspaceModel? _chosenWorkspace;

  // LayerLink connects the button to the floating dropdown
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  void _toggleDropdown(List<WorkspaceModel> workspaces) {
    if (_expanded) {
      _closeDropdown();
    } else {
      _openDropdown(workspaces);
    }
  }

  void _openDropdown(List<WorkspaceModel> workspaces) {
    _overlayEntry = _createOverlayEntry(workspaces);
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

  OverlayEntry _createOverlayEntry(List<WorkspaceModel> workspaces) {
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
              sizeFactor: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
              ),
              axisAlignment: -1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    for (final workspace in workspaces)
                      workspaceItem(workspace),
                    if (workspaces.length > 1)
                      Divider(height: 0, color: Colors.grey.shade300),
                    if (workspaces.length > 1) const SizedBox(height: 8),
                    addWorkspace(hasWorkspaces: workspaces.isNotEmpty),
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
    final workspacesAsync = ref.watch(workspacesProvider);

    return workspacesAsync.when(
      data: (workspaces) {
        if (_chosenWorkspace == null && workspaces.isNotEmpty) {
          // Default to first workspace if none chosen
          _chosenWorkspace = workspaces.first;
        } else if (workspaces.isEmpty) {
          _chosenWorkspace = null;
        } else if (_chosenWorkspace != null &&
            !workspaces.any((w) => w.id == _chosenWorkspace!.id)) {
          // If chosen workspace was deleted or no longer available, reset to first
          _chosenWorkspace = workspaces.first;
        }
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: () => _toggleDropdown(workspaces),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: _expanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _chosenWorkspace != null
                  ? Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _hexToColor(_chosenWorkspace!.color),
                          ),
                        ),
                        Expanded(
                          child: MarqueeText(
                            text: _chosenWorkspace!.name,
                            style: const TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _expanded ? -0.25 : 0,
                          duration: const Duration(milliseconds: 100),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                          ),
                        ),
                      ],
                    )
                  : addWorkspace(),
            ),
          ),
        );
      },
      loading: () => Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, s) => Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Error', style: TextStyle(fontSize: 10)),
        ),
      ),
    );
  }

  Widget workspaceItem(WorkspaceModel workspace) {
    if (workspace.id == _chosenWorkspace?.id) return const SizedBox.shrink();
    return InkWell(
      onTap: () {
        setState(() => _chosenWorkspace = workspace);
        _closeDropdown();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _hexToColor(workspace.color),
                ),
              ),
              Expanded(
                child: MarqueeText(
                  text: workspace.name,
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

  Widget addWorkspace({bool hasWorkspaces = true}) {
    return InkWell(
      onTap: () {
        _closeDropdown();
        context.push('/add-workspace');
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hasWorkspaces ? 8 : 0, 0, 8, 0),
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
              const Center(child: Icon(Icons.add_rounded, size: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
