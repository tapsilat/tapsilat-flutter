import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tapsilat/tapsilat.dart';
import 'package:test/test.dart';

void main() {
  group('TapsilatClient', () {
    late TapsilatOrderRequest request;

    setUp(() {
      request = _buildRequest();
    });

    test('creates order when backend responds with success', () async {
      final mockClient = MockClient((http.Request httpRequest) async {
        expect(httpRequest.method, equals('POST'));
        expect(
          httpRequest.url.toString(),
          equals('https://panel.tapsilat.dev/api/v1/order/create'),
        );

        final body = jsonDecode(httpRequest.body) as Map<String, dynamic>;
        expect(body['amount'], equals(1));
        expect(body['buyer'], isNotNull);

        return http.Response(
          jsonEncode({
            'order_id': '00b4237e-6ec2-4a2b-b51a-8ebf29b028db',
            'reference_id': 'd1ed2a82-3e8c-4323-a9ca-9ef0049d7a5b',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final tapsilat = TapsilatClient(apiKey: 'token', httpClient: mockClient);
      final response = await tapsilat.createOrder(request);

      expect(response.orderId, equals('00b4237e-6ec2-4a2b-b51a-8ebf29b028db'));
      expect(
          response.referenceId, equals('d1ed2a82-3e8c-4323-a9ca-9ef0049d7a5b'));
    });

    test('throws descriptive exception on error responses', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({'message': 'Unauthorized'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final tapsilat = TapsilatClient(apiKey: 'token', httpClient: mockClient);

      await expectLater(
        tapsilat.createOrder(request),
        throwsA(
          isA<TapsilatException>()
              .having(
                  (error) => error.message, 'message', contains('Unauthorized'))
              .having((error) => error.statusCode, 'status', 401),
        ),
      );
    });
  });

  group('TapsilatOrderResponse', () {
    test('builds hosted checkout url', () {
      const response = TapsilatOrderResponse(
        orderId: 'order-123',
        referenceId: 'ref-456',
      );

      expect(
        response.checkoutUri.toString(),
        equals('https://checkout.tapsilat.dev/?reference_id=ref-456'),
      );
    });
  });
}

TapsilatOrderRequest _buildRequest() {
  return const TapsilatOrderRequest(
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
    conversationId: 'conversation-test',
    partialPayment: false,
    paymentMethods: true,
    paymentOptions: const [
      'PAY_WITH_WALLET',
      'PAY_WITH_CARD',
    ],
  );
}
