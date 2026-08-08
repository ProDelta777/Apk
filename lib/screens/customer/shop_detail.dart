import 'package:flutter/material.dart';

class ShopDetailScreen extends StatelessWidget {
  final String shopId;
  final String shopName;

  const ShopDetailScreen({
    Key? key,
    required this.shopId,
    required this.shopName,
  }) : super(key: key);

  void _openChat(BuildContext context) {
    // Navigate to a dedicated chat screen with the shopkeeper
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Chat with Shopkeeper...')),
    );
  }

  void _callShopkeeper(BuildContext context) {
    // Implement url_launcher to call the shopkeeper's phone number
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling Shopkeeper...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopName),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _openChat(context),
            tooltip: 'Chat with Shop',
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _callShopkeeper(context),
            tooltip: 'Call Shop',
          ),
        ],
      ),
      body: FutureBuilder(
        // In reality, this calls SupabaseService().getShopProducts(shopId)
        future: Future.delayed(const Duration(seconds: 1), () => [
          {'id': '1', 'name': 'Aashirvaad Atta 5kg', 'price': 250.0},
          {'id': '2', 'name': 'Tata Salt 1kg', 'price': 25.0},
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
                title: Text(product['name']),
                subtitle: Text('₹${product['price']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Add to local cart state
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${product['name']} to cart')),
                    );
                  },
                  child: const Text('Add'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Cart / Checkout Screen
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('View Cart'),
      ),
    );
  }
}
