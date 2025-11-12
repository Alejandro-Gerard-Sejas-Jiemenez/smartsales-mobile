class Pago {
  final int? id;
  final int facturaId;
  final int residenteId;
  final double monto;
  final String metodoPago;
  final String estado;
  final String? stripePaymentIntentId;
  final String? stripeClientSecret;
  final String? fechaCreacion;
  final String? referenciaPago;
  final String? notas;
  final String? residenteNombre;
  final int? facturaNumero;

  Pago({
    this.id,
    required this.facturaId,
    required this.residenteId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    this.stripePaymentIntentId,
    this.stripeClientSecret,
    this.fechaCreacion,
    this.referenciaPago,
    this.notas,
    this.residenteNombre,
    this.facturaNumero,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    double parseMonto(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Pago(
      id: json['id'],
      facturaId: json['factura'],
      residenteId: json['residente'],
      monto: parseMonto(json['monto']),
      metodoPago: json['metodo_pago'] ?? 'stripe',
      estado: json['estado'] ?? 'pendiente',
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      stripeClientSecret: json['stripe_client_secret'],
      fechaCreacion: json['fecha_creacion'],
      referenciaPago: json['referencia_pago'],
      notas: json['notas'],
      residenteNombre: json['residente_nombre'],
      facturaNumero: json['factura_numero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factura': facturaId,
      'residente': residenteId,
      'monto': monto,
      'metodo_pago': metodoPago,
    };
  }
}

class PaymentIntentResponse {
  final String paymentIntentId;
  final String clientSecret;
  final int pagoId;
  final double monto;
  final int facturaId;

  PaymentIntentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.pagoId,
    required this.monto,
    required this.facturaId,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    // ✅ Función para parsear monto de forma segura
    double parseMonto(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return PaymentIntentResponse(
      paymentIntentId: json['payment_intent_id']?.toString() ?? '',
      clientSecret: json['client_secret']?.toString() ?? '',
      pagoId: json['pago_id'] ?? 0,
      monto: parseMonto(json['monto']),
      facturaId: json['factura_id'] ?? 0,
    );
  }
}
