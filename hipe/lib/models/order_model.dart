import 'product_model.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderItem {
  final ProductModel product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String? address;
  final double shippingFee;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.address,
    this.shippingFee = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get total => subtotal + shippingFee;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        status: OrderStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => OrderStatus.pending,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        address: json['address'] as String?,
        shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'address': address,
        'shipping_fee': shippingFee,
      };
}
