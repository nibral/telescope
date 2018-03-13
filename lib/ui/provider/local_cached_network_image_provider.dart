import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telescope/infrastructure/cache_manager.dart';

class LocalCachedNetworkImageProvider
    extends ImageProvider<LocalCachedNetworkImageProvider> {
  final String url;

  LocalCachedNetworkImageProvider(this.url);

  @override
  ImageStreamCompleter load(LocalCachedNetworkImageProvider key) {
    return new MultiFrameImageStreamCompleter(codec: _loadImage(), scale: 1.0);
  }

  @override
  Future<LocalCachedNetworkImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return new SynchronousFuture<LocalCachedNetworkImageProvider>(this);
  }

  Future<Codec> _loadImage() async {
    Uint8List data = await new CacheManager().get(url);
    return await instantiateImageCodec(data);
  }
}
