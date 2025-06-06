// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaItemHash() => r'30408799ae381fd95c17187749573c341a79b898';

/// See also [mediaItem].
@ProviderFor(mediaItem)
final mediaItemProvider = AutoDisposeStreamProvider<MediaItem?>.internal(
  mediaItem,
  name: r'mediaItemProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mediaItemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MediaItemRef = AutoDisposeStreamProviderRef<MediaItem?>;
String _$playbackStateHash() => r'30032030f30a04107d5cdaee69a1d8cb4c4384ef';

/// See also [playbackState].
@ProviderFor(playbackState)
final playbackStateProvider =
    AutoDisposeStreamProvider<PlaybackState?>.internal(
  playbackState,
  name: r'playbackStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playbackStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaybackStateRef = AutoDisposeStreamProviderRef<PlaybackState?>;
String _$userInfoHash() => r'685d7e3dbd996c2d9b02c72b3be45af2bc290f76';

/// See also [userInfo].
@ProviderFor(userInfo)
final userInfoProvider = AutoDisposeFutureProvider<UserInfoEntity?>.internal(
  userInfo,
  name: r'userInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserInfoRef = AutoDisposeFutureProviderRef<UserInfoEntity?>;
String _$lyricHash() => r'fd840972a572a1ff5bbdc1fd0b0b280fa3cba369';

/// See also [lyric].
@ProviderFor(lyric)
final lyricProvider = AutoDisposeFutureProvider<UserInfoEntity?>.internal(
  lyric,
  name: r'lyricProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lyricHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LyricRef = AutoDisposeFutureProviderRef<UserInfoEntity?>;
String _$mediaColorHash() => r'd64cde0affd97c6f92d8ac7a5a2d14fb0151f800';

/// See also [mediaColor].
@ProviderFor(mediaColor)
final mediaColorProvider = AutoDisposeFutureProvider<PaletteGenerator>.internal(
  mediaColor,
  name: r'mediaColorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mediaColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MediaColorRef = AutoDisposeFutureProviderRef<PaletteGenerator>;
String _$themeModeNotifierHash() => r'b8d15ea60c399a87f3d4892d461309e8c44e0d7e';

/// See also [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
  ThemeModeNotifier.new,
  name: r'themeModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeModeNotifier = AutoDisposeNotifier<ThemeMode>;
String _$boxPanelDetailDataHash() =>
    r'156ad7326d0b0b9aea2a9eaa45e202639e0a32f6';

/// See also [BoxPanelDetailData].
@ProviderFor(BoxPanelDetailData)
final boxPanelDetailDataProvider =
    AutoDisposeNotifierProvider<BoxPanelDetailData, double>.internal(
  BoxPanelDetailData.new,
  name: r'boxPanelDetailDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$boxPanelDetailDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BoxPanelDetailData = AutoDisposeNotifier<double>;
String _$currentRouterPathHash() => r'6433b94e949466cc49bf052a1f376336469b71aa';

/// See also [CurrentRouterPath].
@ProviderFor(CurrentRouterPath)
final currentRouterPathProvider =
    AutoDisposeNotifierProvider<CurrentRouterPath, String>.internal(
  CurrentRouterPath.new,
  name: r'currentRouterPathProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentRouterPathHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentRouterPath = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
