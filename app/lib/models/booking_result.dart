/// Summary of certified Dharamkanta weighbridge record.
class WeighbridgeSummary {
  final String id;
  final String bookingId;
  final double weightKg;
  final double weightTonnes;
  final String? ticketNumber;
  final String? ticketImageUrl;
  final bool disputed;
  final DateTime? measuredAt;

  WeighbridgeSummary({
    required this.id,
    required this.bookingId,
    required this.weightKg,
    required this.weightTonnes,
    this.ticketNumber,
    this.ticketImageUrl,
    this.disputed = false,
    this.measuredAt,
  });

  factory WeighbridgeSummary.fromJson(Map<String, dynamic> json) {
    return WeighbridgeSummary(
      id: json['id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      weightTonnes: (json['weight_tonnes'] as num?)?.toDouble() ?? 0.0,
      ticketNumber: json['ticket_number'] as String?,
      ticketImageUrl: json['ticket_image_url'] as String?,
      disputed: json['disputed'] as bool? ?? false,
      measuredAt: json['measured_at'] != null ? DateTime.tryParse(json['measured_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'weight_kg': weightKg,
    'weight_tonnes': weightTonnes,
    'ticket_number': ticketNumber,
    'ticket_image_url': ticketImageUrl,
    'disputed': disputed,
    'measured_at': measuredAt?.toIso8601String(),
  };
}

/// Summary of simulated factory escrow payment hold and release.
class PaymentSummary {
  final String id;
  final String bookingId;
  final String provider;
  final double? escrowAmountInr;
  final double? finalAmountInr;
  final String status;
  final DateTime? heldAt;
  final DateTime? releasedAt;

  PaymentSummary({
    required this.id,
    required this.bookingId,
    required this.provider,
    this.escrowAmountInr,
    this.finalAmountInr,
    required this.status,
    this.heldAt,
    this.releasedAt,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      id: json['id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      provider: json['provider'] as String? ?? 'simulated_escrow',
      escrowAmountInr: (json['escrow_amount_inr'] as num?)?.toDouble(),
      finalAmountInr: (json['final_amount_inr'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'held',
      heldAt: json['held_at'] != null ? DateTime.tryParse(json['held_at']) : null,
      releasedAt: json['released_at'] != null ? DateTime.tryParse(json['released_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'provider': provider,
    'escrow_amount_inr': escrowAmountInr,
    'final_amount_inr': finalAmountInr,
    'status': status,
    'held_at': heldAt?.toIso8601String(),
    'released_at': releasedAt?.toIso8601String(),
  };
}

/// Complete Booking Result reflecting backend Booking state machine.
class BookingResult {
  final String id;
  final String offerId;
  final String farmerId;
  final String status; // confirmed, picked_up, paid, cancelled
  final double? escrowAmountInr;
  final double? finalPayoutInr;
  final DateTime? confirmedAt;
  final DateTime? pickedUpAt;
  final DateTime? weighedAt;
  final DateTime? paidAt;
  final String? cancelledReason;
  final PaymentSummary? payment;
  final WeighbridgeSummary? weighbridgeRecord;

  BookingResult({
    required this.id,
    required this.offerId,
    required this.farmerId,
    required this.status,
    this.escrowAmountInr,
    this.finalPayoutInr,
    this.confirmedAt,
    this.pickedUpAt,
    this.weighedAt,
    this.paidAt,
    this.cancelledReason,
    this.payment,
    this.weighbridgeRecord,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    return BookingResult(
      id: json['id'] as String? ?? '',
      offerId: json['offer_id'] as String? ?? '',
      farmerId: json['farmer_id'] as String? ?? '',
      status: json['status'] as String? ?? 'confirmed',
      escrowAmountInr: (json['escrow_amount_inr'] as num?)?.toDouble(),
      finalPayoutInr: (json['final_payout_inr'] as num?)?.toDouble(),
      confirmedAt: json['confirmed_at'] != null ? DateTime.tryParse(json['confirmed_at']) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at']) : null,
      weighedAt: json['weighed_at'] != null ? DateTime.tryParse(json['weighed_at']) : null,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      cancelledReason: json['cancelled_reason'] as String?,
      payment: json['payment'] != null ? PaymentSummary.fromJson(json['payment'] as Map<String, dynamic>) : null,
      weighbridgeRecord: json['weighbridge_record'] != null ? WeighbridgeSummary.fromJson(json['weighbridge_record'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'offer_id': offerId,
    'farmer_id': farmerId,
    'status': status,
    'escrow_amount_inr': escrowAmountInr,
    'final_payout_inr': finalPayoutInr,
    'confirmed_at': confirmedAt?.toIso8601String(),
    'picked_up_at': pickedUpAt?.toIso8601String(),
    'weighed_at': weighedAt?.toIso8601String(),
    'paid_at': paidAt?.toIso8601String(),
    'cancelled_reason': cancelledReason,
    'payment': payment?.toJson(),
    'weighbridge_record': weighbridgeRecord?.toJson(),
  };

  BookingResult copyWith({
    String? status,
    double? finalPayoutInr,
    DateTime? pickedUpAt,
    DateTime? weighedAt,
    DateTime? paidAt,
    PaymentSummary? payment,
    WeighbridgeSummary? weighbridgeRecord,
  }) {
    return BookingResult(
      id: id,
      offerId: offerId,
      farmerId: farmerId,
      status: status ?? this.status,
      escrowAmountInr: escrowAmountInr,
      finalPayoutInr: finalPayoutInr ?? this.finalPayoutInr,
      confirmedAt: confirmedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      weighedAt: weighedAt ?? this.weighedAt,
      paidAt: paidAt ?? this.paidAt,
      cancelledReason: cancelledReason,
      payment: payment ?? this.payment,
      weighbridgeRecord: weighbridgeRecord ?? this.weighbridgeRecord,
    );
  }
}
