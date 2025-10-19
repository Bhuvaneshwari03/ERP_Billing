class Product {
  final String id;
  final String name;
  final double rate;
  final double gst;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.rate,
    required this.gst,
    required this.unit,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      rate: (data['rate'] ?? 0).toDouble(),
      gst: (data['gst'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rate': rate,
      'gst': gst,
      'unit': unit,
    };
  }
}
