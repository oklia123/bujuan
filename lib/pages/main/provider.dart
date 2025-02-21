import 'package:bujuan_music/widgets/panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'provider.g.dart';

@riverpod
PanelController panelController(Ref ref) {
  return PanelController();
}

@riverpod
class SlidingPanelDetailData extends _$SlidingPanelDetailData {
  @override
  double build() => 0;

  void updatePanelDetail(double newValue) {
    state = newValue;
  }
}
