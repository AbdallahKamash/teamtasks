import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_prov.g.dart';

@riverpod
class NavIndex extends _$NavIndex {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}