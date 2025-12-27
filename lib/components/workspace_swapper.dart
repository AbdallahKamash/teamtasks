import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workspace_model.dart';
import '../workspace/workspace_prov.dart';
import '../screens/auth/marquee_text.dart';
import '../router/router.dart';

class WorkspaceSwapper extends ConsumerStatefulWidget {
  const WorkspaceSwapper({super.key});

  @override
  ConsumerState<WorkspaceSwapper> createState() => _WorkspaceSwapperState();
}

class _WorkspaceSwapperState extends ConsumerState<WorkspaceSwapper>
    with TickerProviderStateMixin {
  bool _expanded = false;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

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
    if (_overlayEntry == null) return;

    final entry = _overlayEntry;
    _overlayEntry = null;
    if (mounted) setState(() => _expanded = false);

    await _controller.reverse();
    entry?.remove();
  }

  OverlayEntry _createOverlayEntry(List<WorkspaceModel> workspaces) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOut,
                  ),
                  axisAlignment: -1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        for (final workspace in workspaces)
                          _workspaceItem(workspace),
                        if (workspaces.length > 1)
                          Divider(height: 0, color: Colors.grey.shade300),
                        if (workspaces.length > 1) const SizedBox(height: 8),
                        _addWorkspace(hasWorkspaces: workspaces.isNotEmpty),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<WorkspaceModel>>>(workspacesProvider, (
      previous,
      next,
    ) {
      if (!_expanded || _overlayEntry == null) return;
      if (!next.hasValue) return;

      _overlayEntry!.remove();
      _overlayEntry = _createOverlayEntry(next.value!);
      Overlay.of(context).insert(_overlayEntry!);
    });

    final workspacesAsync = ref.watch(workspacesProvider);
    final selected = ref.watch(selectedWorkspaceProvider);

    return workspacesAsync.when(
      loading: _loading,
      error: (_, _) => _error(),
      data: (workspaces) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: () => _toggleDropdown(workspaces),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: selected == null
                  ? _addWorkspace()
                  : Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _hexToColor(selected.color),
                          ),
                        ),
                        Expanded(
                          child: MarqueeText(
                            text: selected.name,
                            style: const TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? -0.25 : 0,
                          duration: const Duration(milliseconds: 100),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _workspaceItem(WorkspaceModel workspace) {
    final selected = ref.read(selectedWorkspaceProvider);
    final selectedNotifier = ref.read(selectedWorkspaceIdProvider.notifier);
    if (workspace.id == selected?.id) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        selectedNotifier.select(workspace.id);
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

  Widget _addWorkspace({bool hasWorkspaces = true}) {
    return InkWell(
      onTap: () {
        _closeDropdown();
        ref.read(routerProvider).push('/add-workspace');
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hasWorkspaces ? 8 : 0, 0, 8, 0),
          child: Row(
            children: const [
              Expanded(
                child: MarqueeText(
                  text: 'إضافة مساحة عمل جديدة',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.add_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loading() => Container(
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
  );

  Widget _error() => Container(
    height: 45,
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(child: Text('Error', style: TextStyle(fontSize: 10))),
  );

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}
