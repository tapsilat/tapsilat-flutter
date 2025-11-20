import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin HTTP client that talks to the Tapsilat Orders API.
class TapsilatClient {
  /// Creates a client that can call the Tapsilat Orders API.
  TapsilatClient({
    required this.apiKey,
    this.baseUrl = _defaultBaseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
  })  : _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  static const String _defaultBaseUrl = 'https://panel.tapsilat.dev/api/v1/';

  /// Bearer token issued by Tapsilat.
  final String apiKey;

  /// Base URL that hosts the Tapsilat REST API.
  final String baseUrl;

  /// Timeout applied to each HTTP request.
  final Duration timeout;

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  /// Creates a new order and returns identifiers supplied by Tapsilat.
  Future<TapsilatOrderResponse> createOrder(
    TapsilatOrderRequest request,
  ) async {
    final uri = _resolveUri('order/create');
    final headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await _httpClient
          .post(uri, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _decodeBody(response.body);
        final orderId = data['order_id'] as String?;
        final referenceId = data['reference_id'] as String?;
        if (orderId == null || referenceId == null) {
          throw TapsilatException(
            message: 'Order response is missing identifiers.',
            statusCode: response.statusCode,
            body: response.body,
          );
        }
        return TapsilatOrderResponse(
          orderId: orderId,
          referenceId: referenceId,
        );
      }

      final status = response.statusCode;
      final errorMessage = _extractErrorMessage(response.body) ??
          'Tapsilat API responded with status $status.';
      throw TapsilatException(
        message: errorMessage,
        statusCode: response.statusCode,
        body: response.body,
      );
    } on TimeoutException catch (error) {
      final requestTarget = uri.toString();
      final timeoutSeconds = timeout.inSeconds;
      throw TapsilatException(
        message: 'Request to $requestTarget timed out after '
            '${timeoutSeconds}s.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw TapsilatException(message: error.message, cause: error);
    }
  }

  /// Releases the internally owned [http.Client], when applicable.
  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  Uri _resolveUri(String path) {
    final normalized = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(normalized).resolve(sanitizedPath);
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException catch (error) {
      throw TapsilatException(message: 'Invalid JSON body', cause: error);
    }

    throw const TapsilatException(message: 'Unexpected JSON structure');
  }

  String? _extractErrorMessage(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['message', 'error', 'detail']) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }

        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is String) {
            return first;
          }
        }
      }
    } catch (_) {
      // Swallow decoding issues and fall back to default error messaging.
    }

    return null;
  }
}

/// Request payload for creating an order.
class TapsilatOrderRequest {
  /// Builds a strongly typed representation of the `/order/create` payload.
  const TapsilatOrderRequest({
    required this.amount,
    required this.taxAmount,
    required this.locale,
    required this.threeDForce,
    required this.currency,
    required this.shippingAddress,
    required this.basketItems,
    required this.billingAddress,
    required this.buyer,
    required this.conversationId,
    required this.partialPayment,
    required this.paymentMethods,
    this.paymentOptions,
  });

  /// Gross amount that will be collected from the customer.
  final num amount;

  /// Total tax amount included in the order.
  final num taxAmount;

  /// Two-letter locale (e.g. `tr`).
  final String locale;

  /// Forces the payment to flow through 3-D Secure channels when true.
  final bool threeDForce;

  /// Currency code such as TRY or USD.
  final String currency;

  /// Where the purchased goods will be shipped.
  final TapsilatShippingAddress shippingAddress;

  /// Items that make up the basket.
  final List<TapsilatBasketItem> basketItems;

  /// Billing address used for tax invoices.
  final TapsilatBillingAddress billingAddress;

  /// Primary buyer information used for fraud checks.
  final TapsilatBuyer buyer;

  /// Unique identifier you control to trace the transaction.
  final String conversationId;

  /// Whether partial payments are enabled for this checkout.
  final bool partialPayment;

  /// Enables the payment methods block in Tapsilat checkout when true.
  final bool paymentMethods;

  /// Allowed payment options (wallet, card, loan, cash, ...).
  final List<String>? paymentOptions;

  /// Converts the request into a plain map ready for JSON encoding.
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'tax_amount': taxAmount,
      'locale': locale,
      'three_d_force': threeDForce,
      'currency': currency,
      'shipping_address': shippingAddress.toJson(),
      'basket_items': basketItems.map((item) => item.toJson()).toList(),
      'billing_address': billingAddress.toJson(),
      'buyer': buyer.toJson(),
      'conversation_id': conversationId,
      'partial_payment': partialPayment,
      'payment_methods': paymentMethods,
      if (paymentOptions != null && paymentOptions!.isNotEmpty)
        'payment_options': paymentOptions,
    };
  }
}

/// Shipping address of the customer.
class TapsilatShippingAddress {
  /// Describes the recipient address for shipments.
  const TapsilatShippingAddress({
    required this.address,
    required this.city,
    required this.contactName,
    required this.country,
    required this.zipCode,
  });

  /// Street level address text.
  final String address;

  /// City that the shipment will be sent to.
  final String city;

  /// Contact person who will receive the package.
  final String contactName;

  /// Country code in ISO-3166 alpha-2 format.
  final String country;

  /// Postal or zip code.
  final String zipCode;

  /// Serializes the address for HTTP transport.
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'contact_name': contactName,
      'country': country,
      'zip_code': zipCode,
    };
  }
}

/// Billing address that includes tax related information.
class TapsilatBillingAddress {
  /// Billing address that additionally collects tax identifiers.
  const TapsilatBillingAddress({
    required this.address,
    required this.city,
    required this.contactName,
    required this.country,
    required this.zipCode,
    required this.billingType,
    required this.contactPhone,
    required this.vatNumber,
    this.district,
  });

  /// Full billing address line.
  final String address;

  /// City of the invoice owner.
  final String city;

  /// Name that appears on the invoice.
  final String contactName;

  /// Country code for the invoice owner.
  final String country;

  /// Postal or zip code for billing.
  final String zipCode;

  /// Type of billing entity such as PERSONAL or COMPANY.
  final String billingType;

  /// Phone number that Tapsilat can use for contact.
  final String contactPhone;

  /// VAT or tax identification number.
  final String vatNumber;

  /// Optional district information when available.
  final String? district;

  /// Serializes the billing address into JSON.
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'contact_name': contactName,
      'country': country,
      'zip_code': zipCode,
      'billing_type': billingType,
      'contact_phone': contactPhone,
      'vat_number': vatNumber,
      if (district != null) 'district': district,
    };
  }
}

/// Buyer profile that Tapsilat needs for fraud checks.
class TapsilatBuyer {
  /// Details about the buyer for risk and compliance checks.
  const TapsilatBuyer({
    required this.city,
    required this.country,
    required this.email,
    required this.gsmNumber,
    required this.id,
    required this.identityNumber,
    required this.registrationAddress,
    required this.name,
    required this.surname,
    required this.zipCode,
  });

  /// City of the buyer.
  final String city;

  /// Country code of the buyer.
  final String country;

  /// Email address associated with the buyer.
  final String email;

  /// GSM number used for SMS verifications.
  final String gsmNumber;

  /// Internal identifier you store for the buyer.
  final String id;

  /// National identity or tax number.
  final String identityNumber;

  /// Registered address used for legal correspondence.
  final String registrationAddress;

  /// Given name of the buyer.
  final String name;

  /// Surname of the buyer.
  final String surname;

  /// Postal or zip code.
  final String zipCode;

  /// Converts buyer data into the expected map structure.
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'email': email,
      'gsm_number': gsmNumber,
      'id': id,
      'identity_number': identityNumber,
      'registration_address': registrationAddress,
      'name': name,
      'surname': surname,
      'zip_code': zipCode,
    };
  }
}

/// Each physical or digital item in the basket.
class TapsilatBasketItem {
  /// Represents a single line item in the customer's basket.
  const TapsilatBasketItem({
    required this.category1,
    required this.category2,
    required this.name,
    required this.id,
    required this.price,
    required this.couponDiscount,
    required this.quantity,
    required this.itemType,
    required this.data,
    required this.quantityUnit,
  });

  /// Primary category describing the product.
  final String category1;

  /// Secondary category when additional grouping is needed.
  final String category2;

  /// Human readable item name.
  final String name;

  /// SKU or product identifier.
  final String id;

  /// Item price before discounts.
  final num price;

  /// Discount applied per item.
  final num couponDiscount;

  /// Number of units purchased.
  final num quantity;

  /// Product type used by Tapsilat (e.g. DigitalPackage).
  final String itemType;

  /// Optional metadata string forwarded to backend systems.
  final String data;

  /// Unit for the quantity such as PCS or KG.
  final String quantityUnit;

  /// Serializes the basket item for transfer to the API.
  Map<String, dynamic> toJson() {
    return {
      'category1': category1,
      'category2': category2,
      'name': name,
      'id': id,
      'price': price,
      'coupon_discount': couponDiscount,
      'quantity': quantity,
      'item_type': itemType,
      'data': data,
      'quantity_unit': quantityUnit,
    };
  }
}

/// Container for identifiers returned after creating an order.
class TapsilatOrderResponse {
  /// Wraps the identifiers returned by the API.
  const TapsilatOrderResponse({
    required this.orderId,
    required this.referenceId,
  });

  static const String _checkoutBaseUrl = 'https://checkout.tapsilat.dev/';

  /// UUID generated by Tapsilat for the order.
  final String orderId;

  /// Reference identifier that can be used to poll for status.
  final String referenceId;

  /// Hosted checkout page that can be presented in a WebView or browser.
  Uri get checkoutUri {
    return Uri.parse(_checkoutBaseUrl)
        .replace(queryParameters: {'reference_id': referenceId});
  }
}

/// Checked exception thrown when the remote API rejects a request.
class TapsilatException implements Exception {
  /// Builds a typed exception based on HTTP or serialization failures.
  const TapsilatException({
    required this.message,
    this.statusCode,
    this.body,
    this.cause,
  });

  /// Human readable description of the failure.
  final String message;

  /// Optional HTTP status returned by the API.
  final int? statusCode;

  /// Raw body that Tapsilat responded with.
  final String? body;

  /// Original exception that triggered the failure, when any.
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('TapsilatException: $message');
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    if (cause != null) {
      buffer.write(', cause: $cause');
    }
    return buffer.toString();
  }
}
