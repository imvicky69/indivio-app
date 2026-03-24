// lib/features/fees/data/fee_model.dart

class FeeModel {
  final String feeId;
  final String schoolId;
  final String studentId;
  final String academicYear;
  final String quarter;
  final double totalAmount;
  final double concession;
  final double lateFine;
  final double netPayable;
  final String dueDate;
  final String status; // 'pending', 'overdue', 'paid'
  final DateTime? paidAt;
  final String? transactionId;
  final String? receiptUrl;

  const FeeModel({
    required this.feeId,
    required this.schoolId,
    required this.studentId,
    required this.academicYear,
    required this.quarter,
    required this.totalAmount,
    required this.concession,
    required this.lateFine,
    required this.netPayable,
    required this.dueDate,
    required this.status,
    this.paidAt,
    this.transactionId,
    this.receiptUrl,
  });

  factory FeeModel.fromMap(Map<String, dynamic> map, String id) {
    return FeeModel(
      feeId: id,
      schoolId: (map['schoolId'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      academicYear: (map['academicYear'] as String?) ?? '',
      quarter: (map['quarter'] as String?) ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      concession: (map['concession'] as num?)?.toDouble() ?? 0.0,
      lateFine: (map['lateFine'] as num?)?.toDouble() ?? 0.0,
      netPayable: (map['netPayable'] as num?)?.toDouble() ?? 0.0,
      dueDate: (map['dueDate'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'pending',
      paidAt: map['paidAt'] != null
          ? DateTime.parse(map['paidAt'] as String)
          : null,
      transactionId: map['transactionId'] as String?,
      receiptUrl: map['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'studentId': studentId,
      'academicYear': academicYear,
      'quarter': quarter,
      'totalAmount': totalAmount,
      'concession': concession,
      'lateFine': lateFine,
      'netPayable': netPayable,
      'dueDate': dueDate,
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
      'receiptUrl': receiptUrl,
    };
  }

  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';
  bool get isPaid => status == 'paid';

  @override
  String toString() =>
      'FeeModel(id: $feeId, studentId: $studentId, status: $status)';
}
