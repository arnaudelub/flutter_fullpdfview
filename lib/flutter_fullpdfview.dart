import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

typedef PDFViewCreatedCallback = void Function(PDFViewController controller);
typedef RenderCallback = void Function(int? pages);
typedef PageChangedCallback = void Function(int? page, int? total);
typedef ErrorCallback = void Function(dynamic error);
typedef PageErrorCallback = void Function(int? page, dynamic error);
typedef LinkHandlerCallback = void Function(String? uri);
typedef ZoomChangedCallback = void Function(double? zoom);

enum bgcolors { BLACK, WHITE, CYAN, BLUE }
enum FitPolicy { WIDTH, HEIGHT, BOTH }

class PDFView extends StatefulWidget {
  const PDFView({
    Key? key,
    this.filePath,
    this.pdfData,
    this.onViewCreated,
    this.onRender,
    this.onPageChanged,
    this.onError,
    this.onPageError,
    this.onZoomChanged,
    this.gestureRecognizers,
    this.dualPageMode = false,
    this.displayAsBook = false,
    this.dualPageWithBreak = false,
    this.fitPolicy = FitPolicy.BOTH,
    this.fitEachPage = true,
    this.enableSwipe = true,
    this.swipeHorizontal = false,
    this.password,
    this.nightMode = false,
    this.autoSpacing = true,
    this.pageFling = true,
    this.pageSnap = true,
    this.defaultPage = 0,
    this.backgroundColor = bgcolors.WHITE,
  }) : super(key: key);

  @override
  _PDFViewState createState() => _PDFViewState();

  /// If not null invoked once the web view is created.
  final PDFViewCreatedCallback? onViewCreated;
  final RenderCallback? onRender;
  final PageChangedCallback? onPageChanged;
  final ZoomChangedCallback? onZoomChanged;
  final ErrorCallback? onError;
  final PageErrorCallback? onPageError;

  /// Which gestures should be consumed by the pdf view.
  ///
  /// It is possible for other gesture recognizers to be competing with the pdf view on pointer
  /// events, e.g if the pdf view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The pdf view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the pdf view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The initial URL to load.
  final String? filePath;
  final Uint8List? pdfData;

  final FitPolicy? fitPolicy;
  final bool fitEachPage;
  final bool enableSwipe;
  final bool swipeHorizontal;
  final String? password;
  final bool nightMode;
  final bool autoSpacing;
  final bool pageFling;
  final bool pageSnap;
  final int defaultPage;
  final bool dualPageMode;
  final bool displayAsBook;
  final bool dualPageWithBreak;
  final bgcolors backgroundColor;
}

class _PDFViewState extends State<PDFView> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.arnaudelub.io/pdfview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.arnaudelub.io/pdfview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the webview_flutter plugin');
  }

  void _onPlatformViewCreated(int id) {
    final PDFViewController controller = PDFViewController._(id, widget);
    _controller.complete(controller);
    if (widget.onViewCreated != null) {
      widget.onViewCreated!(controller);
    }
  }

  @override
  void didUpdateWidget(PDFView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.future.then(
        (PDFViewController controller) => controller._updateWidget(widget));
  }
}

class _CreationParams {
  _CreationParams({
    this.filePath,
    this.pdfData,
    this.settings,
  });

  static _CreationParams fromWidget(PDFView widget) {
    return _CreationParams(
      filePath: widget.filePath,
      pdfData: widget.pdfData,
      settings: _PDFViewSettings.fromWidget(widget),
    );
  }

  final String? filePath;
  final Uint8List? pdfData;

  final _PDFViewSettings? settings;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> params = {
      'filePath': filePath,
      'pdfData': pdfData,
    };

    params.addAll(settings!.toMap());

    return params;
  }
}

class _PDFViewSettings {
  _PDFViewSettings({
    this.enableSwipe,
    this.fitPolicy,
    this.fitEachPage,
    this.swipeHorizontal,
    this.password,
    this.nightMode,
    this.autoSpacing,
    this.pageFling,
    this.pageSnap,
    this.defaultPage,
    this.dualPageMode,
    this.displayAsBook,
    this.backgroundColor,
    this.dualPageWithBreak,
    this.preventLinkNavigation,
  });

  static _PDFViewSettings fromWidget(PDFView widget) {
    return _PDFViewSettings(
      enableSwipe: widget.enableSwipe,
      fitPolicy: widget.fitPolicy,
      fitEachPage: widget.fitEachPage,
      swipeHorizontal: widget.swipeHorizontal,
      password: widget.password,
      nightMode: widget.nightMode,
      autoSpacing: widget.autoSpacing,
      pageFling: widget.pageFling,
      pageSnap: widget.pageSnap,
      defaultPage: widget.defaultPage,
      dualPageMode: widget.dualPageMode,
      displayAsBook: widget.displayAsBook,
      dualPageWithBreak: widget.dualPageWithBreak,
      backgroundColor: convertTtoString(widget.backgroundColor),
    );
  }

  final bool? enableSwipe;
  final bool? swipeHorizontal;
  final String? password;
  final bool? nightMode;
  final bool? autoSpacing;
  final bool? pageFling;
  final bool? pageSnap;
  final int? defaultPage;
  final FitPolicy? fitPolicy;
  final bool? fitEachPage;
  final bool? preventLinkNavigation;
  final bool? dualPageMode;
  final bool? displayAsBook;
  final bool? dualPageWithBreak;
  final String? backgroundColor;

  static String convertTtoString(bgcolors bg) {
    switch (bg) {
      case bgcolors.BLACK:
        return 'black';
      case bgcolors.BLUE:
        return 'blue';
      case bgcolors.CYAN:
        return 'cyan';
      case bgcolors.WHITE:
        return 'white';
      default:
        return 'white';
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enableSwipe': enableSwipe,
      'fitPolicy': fitPolicy.toString(),
      'fitEachPage': fitEachPage,
      'swipeHorizontal': swipeHorizontal,
      'password': password,
      'nightMode': nightMode,
      'autoSpacing': autoSpacing,
      'pageFling': pageFling,
      'pageSnap': pageSnap,
      'defaultPage': defaultPage,
      'dualPageMode': dualPageMode,
      'dualPageWithBreak': dualPageWithBreak,
      'showCover': displayAsBook,
      'backgroundColor': backgroundColor,
    };
  }

  Map<String, dynamic> updatesMap(_PDFViewSettings newSettings) {
    final Map<String, dynamic> updates = <String, dynamic>{};
    if (enableSwipe != newSettings.enableSwipe) {
      updates['enableSwipe'] = newSettings.enableSwipe;
    }
    if (pageFling != newSettings.pageFling) {
      updates['pageFling'] = newSettings.pageFling;
    }
    if (pageSnap != newSettings.pageSnap) {
      updates['pageSnap'] = newSettings.pageSnap;
    }
    if (fitPolicy != newSettings.fitPolicy) {
      updates['fitPolicy'] = newSettings.fitPolicy;
    }
    if (fitEachPage != newSettings.fitEachPage) {
      updates['fitEachPage'] = newSettings.fitEachPage;
    }
    if (dualPageMode != newSettings.dualPageMode) {
      updates['dualPageMode'] = newSettings.dualPageMode;
    }
    if (backgroundColor != newSettings.backgroundColor) {
      updates['backgroundColor'] = newSettings.backgroundColor;
    }

    return updates;
  }
}

class PDFViewController {
  PDFViewController._(
    int id,
    this._widget,
  ) : _channel = MethodChannel('plugins.arnaudelub.io/pdfview_$id') {
    _settings = _PDFViewSettings.fromWidget(_widget);
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final MethodChannel _channel;

  late _PDFViewSettings _settings;

  PDFView _widget;

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRender':
        if (_widget.onRender != null) {
          _widget.onRender!(call.arguments['pages'] as int);
        }

        return null;
      case 'onPageChanged':
        if (_widget.onPageChanged != null) {
          _widget.onPageChanged!(
            call.arguments['page'] as int,
            call.arguments['total'] as int,
          );
        }

        return null;
      case 'onError':
        if (_widget.onError != null) {
          _widget.onError!(call.arguments['error']);
        }

        return null;
      case 'onPageError':
        if (_widget.onPageError != null) {
          _widget.onPageError!(
              call.arguments['page'] as int, call.arguments['error']);
        }

        return null;

      case 'onZoomChanged':
        if (_widget.onZoomChanged != null) {
          _widget.onZoomChanged!(call.arguments['zoom'] as double);
        }
        return null;
    }
    throw MissingPluginException(
        '${call.method} was invoked but has no handler');
  }

  Future<double?> getPageWidth(int page) async {
    final double? pageWidth = await _channel
        .invokeMethod('pageWidth', <String, dynamic>{'page': page});
    return pageWidth;
  }

  Future<double?> getPageHeight(int page) async {
    final double? pageHeight = await _channel
        .invokeMethod('pageHeight', <String, dynamic>{'page': page});
    return pageHeight;
  }

  Future<double?> getScreenWidth() async {
    final double? screenWidth = await _channel.invokeMethod('screenWidth');
    return screenWidth;
  }

  Future<double?> getScreenHeight() async {
    final double? screenHeight = await _channel.invokeMethod('screenHeight');
    return screenHeight;
  }

  Future<int?> getPageCount() async {
    final int? pageCount = await _channel.invokeMethod('pageCount');
    return pageCount;
  }

  Future<int?> getCurrentPage() async {
    final int? currentPage = await _channel.invokeMethod('currentPage');
    return currentPage;
  }

  Future<bool?> setPage(int page) async {
    final bool? isSet =
        await _channel.invokeMethod('setPage', <String, dynamic>{
      'page': page,
    });
    return isSet;
  }

  Future<bool?> setPageWithAnimation(int page) async {
    final bool? isSet =
        await _channel.invokeMethod('setPageWithAnimation', <String, dynamic>{
      'page': page,
    });
    return isSet;
  }

  Future<bool?> resetZoom(int page) async {
    final bool? isSet =
        await _channel.invokeMethod('resetZoom', <String, dynamic>{
      'page': page,
    });
    return isSet;
  }

  Future<bool?> setZoom(double zoom) async {
    print("setting zoom to $zoom");
    final bool? isSet =
        await _channel.invokeMethod('setZoom', <String, dynamic>{
      'newzoom': zoom,
    });
    return isSet;
  }

  Future<double?> getZoom() async {
    final double? zoom = await _channel.invokeMethod('currentZoom');
    return zoom;
  }

  Future<void> _updateWidget(PDFView widget) async {
    _widget = widget;
    await _updateSettings(_PDFViewSettings.fromWidget(widget));
  }

  Future<void> _updateSettings(_PDFViewSettings setting) async {
    final Map<String, dynamic> updateMap = _settings.updatesMap(setting);
    if (updateMap.isEmpty) {
      return null;
    }
    _settings = setting;
    return _channel.invokeMethod('updateSettings', updateMap);
  }
}
