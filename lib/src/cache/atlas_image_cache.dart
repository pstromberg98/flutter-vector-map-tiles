import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:executor_lib/executor_lib.dart';
import 'package:vector_map_tiles/src/gather_logger.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import 'extensions.dart';
import 'storage_cache.dart';

class AtlasImageCache {
  final Theme _theme;
  final Future<Uint8List> Function() _atlasProvider;
  final StorageCache _delegate;
  bool _disposed = false;
  Image? _image;
  Completer<Image>? _loading;

  AtlasImageCache(this._theme, this._atlasProvider, this._delegate);

  Future<Image> retrieve() {
    if (_disposed) {
      GatherLogger.info(
        'AtlasImageCache.retrieve',
        'cancelled',
      );
      return Future.error(CancellationException());
    }
    final image = _image;
    if (image != null) {
      GatherLogger.info(
        'AtlasImageCache.retrieve',
        'Image already in memory',
      );

      return Future.value(image);
    }
    var loading = _loading;
    if (loading != null) {
      return loading.future;
    }
    final loadResult = Completer<Image>();
    _loading = loadResult;
    _load().then((value) {
      if (_disposed) {
        value.dispose();
        loadResult.completeError(CancellationException());
      } else {
        loadResult.complete(value);
      }
    }).onError((error, stackTrace) {
      loadResult.completeError(error ?? '', stackTrace);
    });
    return loadResult.future;
  }

  void dispose() {
    _disposed = true;
    _image?.dispose();
    _image = null;
  }

  Future<Image> _load() async {
    final key = _key();
    GatherLogger.info(
      'AtlasImageCache._load',
      'atlas key: $key',
    );
    var bytes = await _delegate.retrieve(key);
    GatherLogger.info(
      'AtlasImageCache._load',
      'cache result: ${bytes == null ? 'miss' : 'hit'}',
    );
    if (bytes == null) {
      GatherLogger.info(
        'AtlasImageCache._load',
        'Calling atlas provider',
      );
      bytes = await _atlasProvider();
      await _delegate.put(key, bytes);
    }
    GatherLogger.info(
      'AtlasImageCache._load',
      'instantiating image code using bytes of length: ${bytes.length}',
    );
    final codec = await instantiateImageCodec(bytes);
    GatherLogger.info(
      'AtlasImageCache._load',
      'attempting getNextFrame',
    );
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      GatherLogger.error('AtlasImageCache._load', e.toString());
      rethrow;
    }
  }

  String _key() =>
      'icon-atlas-${_theme.id.fileSafe()}-${_theme.version.fileSafe()}.png';
}
