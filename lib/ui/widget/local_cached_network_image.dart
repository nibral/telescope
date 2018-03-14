import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telescope/infrastructure/cache_manager.dart';

class LocalCachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final Widget placeholder;
  final double width;
  final double height;
  final BoxFit fit;

  LocalCachedNetworkImage(this.imageUrl,
      {this.placeholder, this.width, this.height, this.fit});

  @override
  State<StatefulWidget> createState() {
    return new _LocalCachedNetworkImageState();
  }
}

class _LocalCachedNetworkImageState extends State<LocalCachedNetworkImage> {
  _LocalCachedNetworkImageProvider _imageProvider;
  _ImageProviderResolver _providerResolver;
  bool _isLoading;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _imageProvider = new _LocalCachedNetworkImageProvider(widget.imageUrl);
    _providerResolver = new _ImageProviderResolver(this, _updateState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(LocalCachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolveImage();
  }

  @override
  void reassemble() {
    super.reassemble();
    _resolveImage();
  }

  @override
  void dispose() {
    _providerResolver.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.placeholder != null) {
      return widget.placeholder;
    }

    return new RawImage(
      image: _providerResolver._imageInfo?.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  void _resolveImage() {
    _providerResolver.resolve(_imageProvider);
  }

  void _updateState() {
    setState(() {
      if (_isLoading && _providerResolver._imageInfo != null) {
        _isLoading = false;
      }
    });
  }
}

typedef void _ImageProviderResolverListener();

class _ImageProviderResolver {
  final _LocalCachedNetworkImageState state;
  final _ImageProviderResolverListener listener;

  ImageStream _imageStream;
  ImageInfo _imageInfo;

  _ImageProviderResolver(this.state, this.listener);

  void resolve(_LocalCachedNetworkImageProvider provider) {
    final LocalCachedNetworkImage widget = state.widget;
    final ImageStream oldImageStream = _imageStream;
    _imageStream = provider.resolve(createLocalImageConfiguration(state.context,
        size: (widget.width != null && widget.height != null)
            ? new Size(widget.width, widget.height)
            : null));

    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_handleImageChanged);
      _imageStream.addListener(_handleImageChanged);
    }
  }

  void _handleImageChanged(ImageInfo imageInfo, bool asynchronousCall) {
    _imageInfo = imageInfo;
    listener();
  }

  void stopListening() {
    _imageStream?.removeListener(_handleImageChanged);
  }
}

class _LocalCachedNetworkImageProvider
    extends ImageProvider<_LocalCachedNetworkImageProvider> {
  final String url;

  _LocalCachedNetworkImageProvider(this.url);

  @override
  ImageStreamCompleter load(_LocalCachedNetworkImageProvider key) {
    return new MultiFrameImageStreamCompleter(codec: _loadImage(), scale: 1.0);
  }

  @override
  Future<_LocalCachedNetworkImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return new SynchronousFuture<_LocalCachedNetworkImageProvider>(this);
  }

  Future<Codec> _loadImage() async {
    Uint8List data = await new CacheManager().get(url);
    return await instantiateImageCodec(data);
  }
}
