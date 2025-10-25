import 'package:flutter/material.dart';
import 'package:tapsilat/tapsilat.dart';

void main() {
  runApp(const TapsilatExampleApp());
}

class TapsilatExampleApp extends StatelessWidget {
  const TapsilatExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapsilat Plugin Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String? _platformVersion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    setState(() {
      _error = null;
      _platformVersion = null;
    });

    try {
      final version = await Tapsilat.instance.getPlatformVersion();
      if (!mounted) return;
      setState(() {
        _platformVersion = version;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tapsilat Plugin Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _platformVersion != null
                    ? 'Platform version: $_platformVersion'
                    : 'Platform version unavailable',
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadVersion,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
