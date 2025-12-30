class Document {
  final String fileName;
  double _printingCost;
  double get printingCost => _printingCost;
  set printingCost(double value) => _printingCost = value;

  // Add printing settings fields
  int copies;
  String paperSize;
  bool isColor;
  int pageCount;
  // optional: store first page width/height in PDF points (72 pts = 1 inch)
  double? pageWidthPts;
  double? pageHeightPts;
  
  final DateTime uploadTime;
  final DateTime expiryTime;

  Document({
    required this.fileName,
    double printingCost = 0.0,
    this.copies = 1,
    this.paperSize = 'A4',
    this.isColor = true,
    this.pageCount = 1,
    this.pageWidthPts,
    this.pageHeightPts,
    DateTime? uploadTime,
  }) : _printingCost = printingCost,
       uploadTime = uploadTime ?? DateTime.now(),
       expiryTime = (uploadTime ?? DateTime.now()).add(const Duration(hours: 1));

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'printingCost': _printingCost,
        'copies': copies,
        'paperSize': paperSize,
        'isColor': isColor,
        'pageCount': pageCount,
      'pageWidthPts': pageWidthPts,
      'pageHeightPts': pageHeightPts,
        'uploadTime': uploadTime.toIso8601String(),
        'expiryTime': expiryTime.toIso8601String(),
      };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        fileName: json['fileName'],
        printingCost: (json['printingCost'] as num?)?.toDouble() ?? 0.0,
        copies: (json['copies'] as num?)?.toInt() ?? 1,
        paperSize: json['paperSize'] as String? ?? 'A4',
        isColor: json['isColor'] as bool? ?? true,
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 1,
      pageWidthPts: (json['pageWidthPts'] as num?)?.toDouble(),
      pageHeightPts: (json['pageHeightPts'] as num?)?.toDouble(),
      uploadTime: DateTime.parse(json['uploadTime']),
      );

  bool get isExpired => DateTime.now().isAfter(expiryTime);

  Duration get timeRemaining => expiryTime.difference(DateTime.now());

  String get formattedTimeRemaining {
    final remaining = timeRemaining;
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m ${remaining.inSeconds.remainder(60)}s';
    } else {
      return '${remaining.inMinutes}m ${remaining.inSeconds.remainder(60)}s';
    }
  }

  set printingCosts(double printingCosts) {}
}