package com.github.arnaudelub.flutter_fullpdfview;

import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FlutterFullpdfviewPlugin {
    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "plugins.arnaudelub.io/pdfview", new FULLPDFViewFactory(registrar.messenger()));
    }
}
