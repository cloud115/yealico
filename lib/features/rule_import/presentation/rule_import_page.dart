import 'package:flutter/material.dart';

import '../../../core/models/rule_import_request.dart';
import '../domain/rule_import_service.dart';

class RuleImportPage extends StatefulWidget {
  const RuleImportPage({super.key});

  @override
  State<RuleImportPage> createState() => _RuleImportPageState();
}

class _RuleImportPageState extends State<RuleImportPage> {
  final _controller = TextEditingController();
  final _service = RuleImportService();

  bool _isLoading = false;
  String? _errorMessage;
  List<String> _validationErrors = const <String>[];
  RuleImportRequest? _imported;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationErrors = const <String>[];
      _imported = null;
    });

    try {
      final request = await _service.importFromUrl(_controller.text);
      if (!mounted) {
        return;
      }
      setState(() {
        _imported = request;
      });
    } on RuleImportException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.message;
      });
    } on RuleValidationException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Rule validation failed.';
        _validationErrors = e.issues
            .map((issue) => '[${issue.path}] ${issue.message}')
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unknown import error.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rule Import (T04)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'GitHub Raw URL',
                hintText: 'https://raw.githubusercontent.com/...',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _handleImport,
              child: Text(_isLoading ? 'Importing...' : 'Import Rule'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_validationErrors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _validationErrors
                      .take(5)
                      .map((e) => Text('- $e'))
                      .toList(growable: false),
                ),
              ),
            if (_imported != null) _ImportedCard(request: _imported!),
          ],
        ),
      ),
    );
  }
}

class _ImportedCard extends StatelessWidget {
  const _ImportedCard({required this.request});

  final RuleImportRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import request created'),
            const SizedBox(height: 8),
            Text('sourceUrl: ${request.sourceUrl}'),
            Text('siteId: ${request.siteId ?? '(not provided)'}'),
            Text('siteName: ${request.siteName ?? '(not provided)'}'),
            Text('jsonLength: ${request.rawJson.length}'),
          ],
        ),
      ),
    );
  }
}
