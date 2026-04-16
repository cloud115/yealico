import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef VerificationWebViewBuilder = Widget Function(
    BuildContext context, String url);

class SiteVerificationPage extends StatefulWidget {
  const SiteVerificationPage({
    super.key,
    required this.siteName,
    required this.url,
    this.webViewBuilder,
  });

  final String siteName;
  final String url;
  final VerificationWebViewBuilder? webViewBuilder;

  @override
  State<SiteVerificationPage> createState() => _SiteVerificationPageState();
}

class _SiteVerificationPageState extends State<SiteVerificationPage> {
  WebViewController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.webViewBuilder != null) {
      return;
    }

    final uri = Uri.tryParse(widget.url);
    if (uri == null || !uri.isAbsolute) {
      _error = 'Verification URL is invalid.';
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(uri);
    _controller = controller;
  }

  void _doneAndRefresh() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.siteName} Verify Session'),
        actions: [
          TextButton(
            onPressed: _doneAndRefresh,
            child: const Text('Done and Refresh'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (widget.webViewBuilder != null) {
      return widget.webViewBuilder!(context, widget.url);
    }
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WebViewWidget(controller: controller);
  }
}
