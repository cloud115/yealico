package com.tclxuser.yealico

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class RenderedPageFetcher(
    private val activity: FlutterActivity,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var activeWebView: WebView? = null

    fun getCookiesForUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("invalid_args", "url is required", null)
            return
        }

        activity.runOnUiThread {
            result.success(CookieManager.getInstance().getCookie(url).orEmpty())
        }
    }

    fun fetch(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        val userAgent = call.argument<String>("userAgent")
        val timeoutMs = call.argument<Int>("timeoutMs") ?: 5000
        val decryptScript = call.argument<String>("decryptScript")

        if (url.isNullOrBlank() || userAgent.isNullOrBlank()) {
            result.error("invalid_args", "url and userAgent are required", null)
            return
        }

        activity.runOnUiThread {
            fetchOnMainThread(
                url = url,
                userAgent = userAgent,
                timeoutMs = timeoutMs.toLong(),
                decryptScript = decryptScript,
                result = result,
            )
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun fetchOnMainThread(
        url: String,
        userAgent: String,
        timeoutMs: Long,
        decryptScript: String?,
        result: MethodChannel.Result,
    ) {
        cleanupWebView()

        val rootView = activity.findViewById<ViewGroup>(android.R.id.content)
        val webView = WebView(activity)
        var completed = false

        fun finishSuccess(payload: Map<String, Any?>) {
            if (completed) {
                return
            }
            completed = true
            CookieManager.getInstance().flush()
            result.success(payload)
            cleanupWebView()
        }

        fun finishError(code: String, message: String) {
            if (completed) {
                return
            }
            completed = true
            result.error(code, message, null)
            cleanupWebView()
        }

        val timeoutRunnable = Runnable {
            finishError("timeout", "Timed out waiting for rendered page.")
        }

        activeWebView = webView
        CookieManager.getInstance().setAcceptCookie(true)
        webView.layoutParams = FrameLayout.LayoutParams(1, 1)
        webView.alpha = 0f
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.settings.loadsImagesAutomatically = true
        webView.settings.userAgentString = userAgent
        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                mainHandler.removeCallbacks(timeoutRunnable)
                mainHandler.postDelayed(timeoutRunnable, timeoutMs)
            }

            override fun onReceivedError(
                view: WebView,
                request: WebResourceRequest,
                error: WebResourceError,
            ) {
                super.onReceivedError(view, request, error)
                if (request.isForMainFrame) {
                    finishError("page_error", error.description.toString())
                }
            }

            override fun onPageFinished(view: WebView, url: String) {
                super.onPageFinished(view, url)
                mainHandler.postDelayed({
                    view.evaluateJavascript(
                        """
                        (function() {
                          return JSON.stringify({
                            html: document.documentElement.outerHTML,
                            title: document.title || '',
                            ready: document.readyState || '',
                            url: location.href || ''
                          });
                        })();
                        """.trimIndent(),
                    ) { payloadJson ->
                        try {
                            val payload = JSONObject(decodeJsString(payloadJson))
                            val finalUrl = payload.getString("url")
                            val title = payload.optString("title")
                            val html = payload.getString("html")
                            val cookies =
                                CookieManager.getInstance().getCookie(finalUrl).orEmpty()
                            val challengeDetected = detectChallenge(finalUrl, title)

                            if (decryptScript.isNullOrBlank()) {
                                finishSuccess(
                                    mapOf(
                                        "finalUrl" to finalUrl,
                                        "html" to html,
                                        "title" to title,
                                        "cookies" to cookies,
                                        "decryptResult" to null,
                                        "challengeDetected" to challengeDetected,
                                    ),
                                )
                                return@evaluateJavascript
                            }

                            view.evaluateJavascript(decryptScript) { decryptJson ->
                                finishSuccess(
                                    mapOf(
                                        "finalUrl" to finalUrl,
                                        "html" to html,
                                        "title" to title,
                                        "cookies" to cookies,
                                        "decryptResult" to decodeJsString(decryptJson),
                                        "challengeDetected" to challengeDetected,
                                    ),
                                )
                            }
                        } catch (error: Exception) {
                            finishError("parse_error", error.message ?: "Failed to parse rendered page.")
                        }
                    }
                }, 300)
            }
        }

        rootView.addView(webView)
        mainHandler.postDelayed(timeoutRunnable, timeoutMs)
        webView.loadUrl(url)
    }

    private fun cleanupWebView() {
        mainHandler.removeCallbacksAndMessages(null)
        val webView = activeWebView ?: return
        activeWebView = null
        (webView.parent as? ViewGroup)?.removeView(webView)
        webView.stopLoading()
        webView.destroy()
    }

    private fun detectChallenge(url: String, title: String): Boolean {
        return url.contains("challenge", ignoreCase = true) ||
            url.contains("cloudflare", ignoreCase = true) ||
            title.contains("challenge", ignoreCase = true) ||
            title.contains("cloudflare", ignoreCase = true)
    }

    private fun decodeJsString(raw: String?): String {
        return raw.orEmpty()
            .removeSurrounding("\"")
            .replace("\\\\", "\\")
            .replace("\\n", "\n")
            .replace("\\\"", "\"")
            .replace("\\u003C", "<")
            .replace("\\u003E", ">")
            .replace("\\/", "/")
    }
}
