import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton pattern for the service
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Expose the Supabase client
  final SupabaseClient client = Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  }

  // --- Auth Examples ---

  Future<AuthResponse> signInWithPhone(String phone, String password) async {
    return await client.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  String? get currentUserId => client.auth.currentUser?.id;

  // --- Data Examples ---

  /// Find nearby shops using a PostGIS RPC function (assuming you create one named 'get_nearby_shops')
  Future<List<Map<String, dynamic>>> getNearbyShops(double lat, double lng, {int radiusInMeters = 5000}) async {
    final response = await client.rpc('get_nearby_shops', params: {
      'p_lat': lat,
      'p_lng': lng,
      'p_radius': radiusInMeters,
    });

    // In a real scenario, you'd parse this into Shop models
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get products for a specific shop
  Future<List<Map<String, dynamic>>> getShopProducts(String shopId) async {
    final response = await client
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .eq('is_available', true);

    return List<Map<String, dynamic>>.from(response);
  }

  // --- Realtime Chat Placeholder ---

  /// Listen to chat messages (assuming a messages table exists)
  RealtimeChannel listenToChat(String orderId, void Function(dynamic payload) onMessage) {
    return client
      .channel('public:messages')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'order_id', value: orderId),
        callback: onMessage,
      )
      .subscribe();
  }
}
