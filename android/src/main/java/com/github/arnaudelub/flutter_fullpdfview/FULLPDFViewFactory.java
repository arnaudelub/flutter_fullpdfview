package com.github.arnaudelub.flutter_fullpdfview;

import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FULLPDFViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public FULLPDFViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @SuppressWarnings("unchecked")
    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> params = (Map<String, Object>) args;
        return new FlutterFullPDFView(context, messenger, id, params);
    }
}
