package com.github.arnaudelub.flutter_fullpdfview;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Color;
import android.view.View;
import com.github.arnaudelub.pdfviewer.PDFView;
import com.github.arnaudelub.pdfviewer.listener.*;
import com.github.arnaudelub.pdfviewer.util.Constants;
import com.github.arnaudelub.pdfviewer.util.FitPolicy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class FlutterFullPDFView implements PlatformView, MethodCallHandler {
  private final PDFView pdfView;
  private final MethodChannel methodChannel;

  @SuppressWarnings("unchecked")
  FlutterFullPDFView(
      Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {
    pdfView = new PDFView(context, null);

    methodChannel = new MethodChannel(messenger, "plugins.arnaudelub.io/pdfview_" + id);
    methodChannel.setMethodCallHandler(this);

    if (params.containsKey("filePath")) {
      String filePath = (String) params.get("filePath");

      File file = new File(filePath);

      Constants.PRELOAD_OFFSET = 3;

      boolean isLandscape;
      int orientation = context.getResources().getConfiguration().orientation;
      isLandscape = orientation == Configuration.ORIENTATION_LANDSCAPE;
      boolean dualMode = getBoolean(params, "dualPageMode");

      pdfView
          .fromFile(file)
          .landscapeOrientation(isLandscape)
          .enableAnnotationRendering(true)
          .dualPageMode(getBoolean(params, "dualPageMode"))
          .enableSwipe(getBoolean(params, "enableSwipe"))
          // .pageFitPolicy(getFitPolicy(params))
          .pageFitPolicy(FitPolicy.BOTH)
          .fitEachPage(dualMode ? false : getBoolean(params, "fitEachPage"))
          .swipeHorizontal(getBoolean(params, "swipeHorizontal"))
          .password(getString(params, "password"))
          .nightMode(getBoolean(params, "nightMode"))
          .autoSpacing(dualMode ? false : getBoolean(params, "autoSpacing"))
          .pageFling(getBoolean(params, "pageFling"))
          .pageSnap(getBoolean(params, "pageSnap"))
          .backgroundColor(getColorFromString(getString(params, "backgroundColor")))
          .onPageChange(
              new OnPageChangeListener() {
                @Override
                public void onPageChanged(int page, int total) {
                  Map<String, Object> args = new HashMap<>();
                  args.put("page", page);
                  args.put("total", total);
                  methodChannel.invokeMethod("onPageChanged", args);
                }
              })
          .onError(
              new OnErrorListener() {
                @Override
                public void onError(Throwable t) {
                  Map<String, Object> args = new HashMap<>();
                  args.put("error", t.toString());
                  methodChannel.invokeMethod("onError", args);
                }
              })
          .onPageError(
              new OnPageErrorListener() {
                @Override
                public void onPageError(int page, Throwable t) {
                  Map<String, Object> args = new HashMap<>();
                  args.put("page", page);
                  args.put("error", t.toString());
                  methodChannel.invokeMethod("onPageError", args);
                }
              })
          .onRender(
              new OnRenderListener() {
                @Override
                public void onInitiallyRendered(int pages) {
                  Map<String, Object> args = new HashMap<>();
                  args.put("pages", pages);
                  methodChannel.invokeMethod("onRender", args);
                }
              })
          .enableDoubletap(true)
          .defaultPage(getInt(params, "defaultPage"))
          .load();
    }
  }

  @Override
  public View getView() {
    return pdfView;
  }

  @Override
  public void onMethodCall(MethodCall methodCall, Result result) {
    switch (methodCall.method) {
      case "pageCount":
        getPageCount(result);
        break;
      case "currentPage":
        getCurrentPage(result);
        break;
      case "setPage":
        setPage(methodCall, result, false);
        break;
      case "setPageWithAnimation":
        setPage(methodCall, result, true);
        break;
      case "resetZoom":
        resetZoom(methodCall, result);
        break;
      case "updateSettings":
        updateSettings(methodCall, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  void getPageCount(Result result) {
    result.success(pdfView.getPageCount());
  }

  void getCurrentPage(Result result) {
    result.success(pdfView.getCurrentPage());
  }

  void setPage(MethodCall call, Result result, boolean withAnimation) {
    int page = (int) call.argument("page");
    pdfView.jumpTo(page, withAnimation);
    result.success(true);
  }

  void resetZoom(MethodCall call, Result result) {
    int page = (int) call.argument("page");
    pdfView.fitToWidth(page);
    result.success(true);
  }

  @SuppressWarnings("unchecked")
  private void updateSettings(MethodCall methodCall, Result result) {
    applySettings((Map<String, Object>) methodCall.arguments);
    result.success(null);
  }

  private void applySettings(Map<String, Object> settings) {
    for (String key : settings.keySet()) {
      switch (key) {
        case "enableSwipe":
          pdfView.setSwipeEnabled(getBoolean(settings, key));
          break;
        case "nightMode":
          pdfView.setNightMode(getBoolean(settings, key));
          break;
        case "pageFling":
          pdfView.setPageFling(getBoolean(settings, key));
          break;
        case "pageSnap":
          pdfView.setPageSnap(getBoolean(settings, key));
          break;
        case "fitEachPage":
          pdfView.setFitEachPage(getBoolean(settings, key));
          break;
        default:
          throw new IllegalArgumentException("Unknown PDFView setting: " + key);
      }
    }
  }

  @Override
  public void dispose() {
    methodChannel.setMethodCallHandler(null);
  }

  boolean getBoolean(Map<String, Object> params, String key) {
    return params.containsKey(key) ? (boolean) params.get(key) : false;
  }

  String getString(Map<String, Object> params, String key) {
    return params.containsKey(key) ? (String) params.get(key) : "";
  }

  int getInt(Map<String, Object> params, String key) {
    return params.containsKey(key) ? (int) params.get(key) : 0;
  }

  int getColorFromString(String color) {
    switch (color) {
      case "black":
        return Color.BLACK;
      case "blue":
        return Color.BLUE;
      case "white":
        return Color.WHITE;
      case "cyan":
        return Color.CYAN;
      default:
        throw new IllegalArgumentException("Unknown color: " + color);
    }
  }

  FitPolicy getFitPolicy(Map<String, Object> params) {
    String fitPolicy = getString(params, "fitPolicy");
    switch (fitPolicy) {
      case "FitPolicy.WIDTH":
        return FitPolicy.WIDTH;
      case "FitPolicy.HEIGHT":
        return FitPolicy.HEIGHT;
      case "FitPolicy.BOTH":
      default:
        return FitPolicy.BOTH;
    }
  }
}
