import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_map_tiles/src/gather_logger.dart';

Future<Image> imageFrom({required Uint8List bytes}) async {
  GatherLogger.info(
    'imageFrom',
    'Attempting to convert bytes of length: ${bytes.lengthInBytes}',
  );
  final codec = await instantiateImageCodec(bytes);
  GatherLogger.info('imageFrom', 'Instantiated image codec');
  try {
    final frame = await codec.getNextFrame();
    return frame.image;
  } finally {
    codec.dispose();
  }
}
