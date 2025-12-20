import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceButton extends ConsumerStatefulWidget {
  const WorkspaceButton({super.key});

  @override
  ConsumerState<WorkspaceButton> createState() => _WorkspaceButtonState();
}

class _WorkspaceButtonState extends ConsumerState<WorkspaceButton>
    with TickerProviderStateMixin {
  bool _expanded = false;
  String chosen = 'Workspace';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TOP BUTTON
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
              borderRadius: BorderRadius.vertical(top: Radius.circular(_expanded ? 12 : 0))
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: .center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8),
                  height: 30, width: 30, decoration: BoxDecoration(
                  borderRadius: .circular(5),
                  color: Colors.purple.shade100
                ),),
                Text(
                  chosen,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // ROTATING ARROW
                AnimatedRotation(
                  turns: _expanded ? -0.25 : 0, // 0.25 = 90°
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // EXPANDABLE LIST
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded
              ? AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(_expanded ? 12 : 0))
            ),
            child: Column(
              children: [
                _item('Workspace 1'),
                _item('Workspace'),
                _item('Create new workspace'),
              ],
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _item(String text) {
    if (text != chosen) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: () {
            setState(() {
              chosen = text;
              _expanded = false;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: .center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 8),
                height: 30, width: 30, decoration: BoxDecoration(
                  borderRadius: .circular(5),
                  color: Colors.purple.shade100
              ),),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}