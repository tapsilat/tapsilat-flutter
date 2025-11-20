# tapsilat

Tapsilat Flutter SDK provides a thin HTTP client around the Tapsilat Orders API so you can create secure checkout sessions directly from your Flutter apps.

## Installation

```yaml
dependencies:
  tapsilat: ^0.3.0
```

Run `flutter pub get` afterwards.

## Quick start

```dart
import 'package:tapsilat/tapsilat.dart';

Future<void> main() async {
  final tapsilat = TapsilatClient(apiKey: 'YOUR_TOKEN');

  final response = await tapsilat.createOrder(
    TapsilatOrderRequest(
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
        registrationAddress: 'Kazim Karabekir Cd. 69',
        name: 'Sample',
        surname: 'User',
        zipCode: '34944',
      ),
      conversationId: 'conversation-${DateTime.now().millisecondsSinceEpoch}',
      partialPayment: false,
      paymentMethods: true,
      paymentOptions: const [
        'PAY_WITH_WALLET',
        'PAY_WITH_CARD',
        'PAY_WITH_LOAN',
        'PAY_WITH_CASH',
      ],
    ),
  );

  print('Order ID: ${response.orderId}');
  print('Reference ID: ${response.referenceId}');
  print('Checkout URL: ${response.checkoutUri}');
  tapsilat.close();
}
```

## Present the hosted checkout

The `reference_id` returned by the API enables a hosted checkout page that
resides at `https://checkout.tapsilat.dev/`. Every `TapsilatOrderResponse`
exposes a `checkoutUri` that you can feed into a `WebView` or into an
`url_launcher` flow:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => CheckoutWebView(initialUri: response.checkoutUri),
  ),
);
```

## Sample cURL call

```
curl --location 'https://panel.tapsilat.dev/api/v1/order/create' \
--header 'Authorization: Bearer YOUR_TOKEN' \
--header 'Content-Type: application/json' \
--data-raw '{
  "amount": 1,
  "tax_amount": 0,
  "locale": "tr",
  "three_d_force": true,
  "currency": "TRY",
  "shipping_address": {
    "address": "Kazim Karabekir Cd. 69",
    "city": "Istanbul",
    "contact_name": "Sample User",
    "country": "TR",
    "zip_code": "34944"
  },
  "basket_items": [
    {
      "category1": "Digital Products",
      "category2": "Subscriptions",
      "name": "Demo Package",
      "id": "item_demo_001",
      "price": 1,
      "coupon_discount": 0,
      "quantity": 1,
      "item_type": "DigitalPackage",
      "data": "CUSTOMER",
      "quantity_unit": "PCE"
    }
  ],
  "billing_address": {
    "address": "Kazim Karabekir Cd. 69",
    "city": "Istanbul",
    "contact_name": "Sample User",
    "country": "TR",
    "zip_code": "34944",
    "billing_type": "PERSONAL",
    "contact_phone": "+905300000000",
    "district": "Tuzla",
    "vat_number": "11111111111"
  },
  "buyer": {
    "city": "Istanbul",
    "country": "TR",
    "email": "sample@example.com",
    "gsm_number": "+905300000000",
    "id": "buyer_demo_001",
    "identity_number": "11111111111",
    "registration_address": "Kazim Karabekir Cd. 69",
    "name": "Sample",
    "surname": "User",
    "zip_code": "34944"
  },
  "conversation_id": "conversation-demo",
  "partial_payment": false,
  "payment_methods": true,
  "payment_options": [
    "PAY_WITH_WALLET",
    "PAY_WITH_CARD",
    "PAY_WITH_LOAN",
    "PAY_WITH_CASH"
  ]
}'
```

The API responds with:

```
{"order_id":"00b4237e-6ec2-4a2b-b51a-8ebf29b028db","reference_id":"d1ed2a82-3e8c-4323-a9ca-9ef0049d7a5b"}
```

## Running the example

- Update the demo app in `example/lib/main.dart` with your bearer token.
- Run `flutter run`, press **Create order**, then tap **Open checkout
  WebView** to complete the payment.

## Tests

```
flutter test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.