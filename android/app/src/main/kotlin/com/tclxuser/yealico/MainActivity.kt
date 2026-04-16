package com.tclxuser.yealico

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var renderedPageMethodHandler: RenderedPageMethodHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        renderedPageMethodHandler = RenderedPageMethodHandler(
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }
}
