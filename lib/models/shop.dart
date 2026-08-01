class Shop {
  final String id;
  final String shopkeeperId;
  final String name;
  final String? description;
  final String address;
  final bool isOpen;

  // Note: Location handling requires parsing PostGIS geometry.
  // In a real app, you would translate this to lat/lng.
  // We'll keep it simple for the model representation.
  final double? latitude;
  final double? longitude;

  Shop({
    required this.id,
    required this.shopkeeperId,
    required this.name,
    this.description,
    required this.address,
    required this.isOpen,
    this.latitude,
    this.longitude,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      shopkeeperId: json['shopkeeper_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      isOpen: json['is_open'] as bool? ?? false,
      // Location extraction logic depends on the specific Supabase RPC output.
      // Often returned as geojson or extracted explicitly via custom views/RPC.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopkeeper_id': shopkeeperId,
      'name': name,
      'description': description,
      'address': address,
      'is_open': isOpen,
    };
  }
}
