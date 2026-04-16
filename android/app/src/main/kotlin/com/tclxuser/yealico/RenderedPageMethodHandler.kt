package com.tclxuser.yealico

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RenderedPageMethodHandler(
    private val activity: FlutterActivity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "yealico/rendered_page")
    private val fetcher = RenderedPageFetcher(activity)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "fetchRenderedPage" -> fetcher.fetch(call, result)
            "getCookiesForUrl" -> fetcher.getCookiesForUrl(call, result)
            else -> result.notImplemented()
        }
    }
}
