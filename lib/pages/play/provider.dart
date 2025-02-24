import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palette_generator/palette_generator.dart';

part 'provider.g.dart';

@riverpod
Future<PaletteGenerator> getImageColor(Ref ref, ImageProvider imageProvider) async {
  return await PaletteGenerator.fromImageProvider(imageProvider, size: const Size(300, 300));
}
