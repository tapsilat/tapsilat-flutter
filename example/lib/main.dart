import 'package:flutter/material.dart';
import 'package:tapsilat/tapsilat.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Bootstraps the sample app that demonstrates order creation.
void main() {
  runApp(const TapsilatExampleApp());
}

/// Root widget that wires up theming for the sample showcase.
class TapsilatExampleApp extends StatelessWidget {
  /// Creates the app container.
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

/// Simple screen that exposes a form for order creation.
class ExampleHomePage extends StatefulWidget {
  /// Builds the stateful order form used in the demo.
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final TextEditingController _apiKeyController = TextEditingController();
  TapsilatOrderResponse? _latestOrder;
  String? _result;
  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _error = 'Enter a valid API key to continue.';
        _result = null;
        _latestOrder = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
      _result = null;
      _latestOrder = null;
    });

    final client = TapsilatClient(apiKey: apiKey);
    try {
      final response = await client.createOrder(_buildSampleRequest());
      if (!mounted) return;
      setState(() {
        _latestOrder = response;
        _result = 'Order ID: ${response.orderId}\n'
            'Reference ID: ${response.referenceId}';
      });
    } on TapsilatException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _latestOrder = null;
      });
    } finally {
      client.close();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openCheckout() async {
    final order = _latestOrder;
    if (order == null) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutWebView(initialUri: order.checkoutUri),
      ),
    );
  }

  TapsilatOrderRequest _buildSampleRequest() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return TapsilatOrderRequest(
      amount: 1,
      taxAmount: 0,
      locale: 'tr',
      threeDForce: true,
      currency: 'TRY',
      shippingAddress: const TapsilatShippingAddress(
        address: 'Kazim Karabekir Cd. 69',
        city: 'Istanbul',
        contactName: 'Sample User',
        country: 'TR',
        zipCode: '34944',
      ),
      basketItems: const [
        TapsilatBasketItem(
          category1: 'Digital Products',
          category2: 'Subscriptions',
          name: 'Demo Package',
          id: 'item_demo_001',
          price: 1,
          couponDiscount: 0,
          quantity: 1,
          itemType: 'DigitalPackage',
          data: 'CUSTOMER',
          quantityUnit: 'PCE',
        ),
      ],
      billingAddress: const TapsilatBillingAddress(
        address: 'Kazim Karabekir Cd. 69',
        city: 'Istanbul',
        contactName: 'Sample User',
        country: 'TR',
        zipCode: '34944',
        billingType: 'PERSONAL',
        contactPhone: '+905300000000',
        vatNumber: '11111111111',
        district: 'Tuzla',
      ),
      buyer: const TapsilatBuyer(
        city: 'Istanbul',
        country: 'TR',
        email: 'sample@example.com',
        gsmNumber: '+905300000000',
        id: 'buyer_demo_001',
        identityNumber: '11111111111',
        registrationAddress: 'Atatürk Cd. 1881',
        name: 'Sample',
        surname: 'User',
        zipCode: '34944',
      ),
      conversationId: 'conversation-$now',
      partialPayment: false,
      paymentMethods: true,
      paymentOptions: const [
        'PAY_WITH_WALLET',
        'PAY_WITH_CARD',
        'PAY_WITH_LOAN',
        'PAY_WITH_CASH',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16;
    return Scaffold(
      appBar: AppBar(title: const Text('Tapsilat Order Demo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API key',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: spacing),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _createOrder,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.shopping_cart_checkout),
                  label: Text(
                    _isSubmitting ? 'Creating order…' : 'Create order',
                  ),
                ),
                if (_latestOrder != null) ...[
                  SizedBox(height: spacing),
                  FilledButton.icon(
                    onPressed: _openCheckout,
                    icon: const Icon(Icons.payment),
                    label: const Text('Open checkout WebView'),
                  ),
                ],
                if (_result != null) ...[
                  SizedBox(height: spacing),
                  Text(
                    _result!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                if (_error != null) ...[
                  SizedBox(height: spacing),
                  Text(
                    _error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                SizedBox(height: spacing),
                const Text(
                  'Tip: The demo sends the exact JSON shown in the README. '
                  'Provide a valid Tapsilat API key '
                  'before triggering the request.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal WebView screen that loads the hosted Tapsilat checkout page.
class CheckoutWebView extends StatefulWidget {
  /// Creates a WebView that points to the given checkout URL.
  const CheckoutWebView({super.key, required this.initialUri});

  /// Checkout URL returned from the Tapsilat API.
  final Uri initialUri;

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(widget.initialUri);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tapsilat Checkout')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
