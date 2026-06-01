class ReceiptModel {
  final String id;             
  final String userId;          
  final String imageUrl;        
  final String mimeType;        
  final double? extractedAmount; 
  final String? merchantName;  
  final String? extractedDate; 
  final String? extractedDescription;
  final String status;          
  final String? transactionId; 
  final String? createdAt;     

  ReceiptModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.mimeType = 'image/jpeg',
    this.extractedAmount,
    this.merchantName,
    this.extractedDate,
    this.extractedDescription,
    this.status = 'pending',
    this.transactionId,
    this.createdAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id:                   json['_id'] ?? '',
      userId:               json['user'] ?? '',
      imageUrl:             json['imageUrl'] ?? '',
      mimeType:             json['mimeType'] ?? 'image/jpeg',
      extractedAmount:      json['extractedAmount'] != null ? (json['extractedAmount']).toDouble() : null,
      merchantName:         json['merchantName'],
      extractedDate:        json['extractedDate'],
      extractedDescription: json['extractedDescription'],
      status:               json['status'] ?? 'pending',
      transactionId:        json['transaction'],
      createdAt:            json['createdAt'],
    );
  }

  bool get isProcessed => status == 'processed';

  bool get isPending => status == 'pending';

  bool get isLinked => transactionId != null && transactionId!.isNotEmpty;

  Map<String, dynamic> get suggestedTransaction {
    return {
      'amount':      extractedAmount ?? 0,
      'description': merchantName ?? extractedDescription ?? '',
      'date':        extractedDate ?? '',
    };
  }
}