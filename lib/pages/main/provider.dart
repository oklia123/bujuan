import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../widgets/slide.dart';

part 'provider.g.dart';

@riverpod
PanelController panelController(Ref ref) {
  return PanelController();
}

@riverpod
BoxController boxController(Ref ref) {
  return BoxController();
}

@riverpod
class SlidingPanelDetailData extends _$SlidingPanelDetailData {
  @override
  double build() => 0;

  void updatePanelDetail(double newValue) {
    state = newValue;
  }
}

@riverpod
class CurrentRouterPath extends _$CurrentRouterPath {
  @override
  String build() => '/';

  void updatePanelDetail(String newValue) {
    state = newValue;
  }
}

@riverpod
class SlidingPanelShow extends _$SlidingPanelShow {
  @override
  bool build() => false;

  void updatePanelShow(bool newValue) {
    state = newValue;
  }
}
