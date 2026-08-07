import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/mesh_network_service.dart';
import '../services/chat_provider.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final network = Provider.of<MeshNetworkService>(context, listen: false);
      network.startAdvertising();
      network.startDiscovery();
    });
  }

  void _showMyQR() {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text("My QR Code"),
              content: SizedBox(
                  width: 250,
                  height: 250,
                  child: Center(
                      child: QrImageView(
                          data: chatProvider.myId,
                          version: QrVersions.auto,
                          size: 200.0,
                      ),
                  ),
              ),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
              ]
          )
      );
  }

  void _scanQR() {
      showDialog(
          context: context,
          builder: (context) => Dialog(
              child: SizedBox(
                  height: 300,
                  child: MobileScanner(
                      onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Scanned ID: ${barcode.rawValue}")));
                                  // In a full implementation, you would add this ID to contacts and initiate connection
                                  break;
                              }
                          }
                      },
                  )
              )
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    final network = Provider.of<MeshNetworkService>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("BlueChat", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showMyQR,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQR,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNetworkStatusRow(network),
          const Divider(),
          if (network.discoveredDevices.isNotEmpty) _buildDiscoveredSection(network),
          Expanded(
            child: chatProvider.contacts.isEmpty
                ? const Center(child: Text("No chats yet. Connect with a nearby device!"))
                : ListView.builder(
                    itemCount: chatProvider.contacts.length,
                    itemBuilder: (context, index) {
                      final contact = chatProvider.contacts[index];
                      final isConnected = network.connectedDevices.containsKey(contact.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isConnected ? Colors.green : Colors.grey,
                          child: Text(contact.name[0].toUpperCase()),
                        ),
                        title: Text(contact.name),
                        subtitle: Text(isConnected ? "Connected" : "Offline"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(contactId: contact.id, contactName: contact.name),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           if (network.connectedDevices.isNotEmpty) {
               for (var id in network.connectedDevices.keys) {
                   chatProvider.sendMessage(id, "🚨 SOS Emergency Alert!");
               }
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Broadcast Sent')));
           } else {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No devices connected to send SOS')));
           }
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.warning, color: Colors.white),
        label: const Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNetworkStatusRow(MeshNetworkService network) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                network.isAdvertising ? Icons.bluetooth_audio : Icons.bluetooth_disabled,
                color: network.isAdvertising ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(network.isAdvertising ? "Visible" : "Hidden"),
            ],
          ),
          Row(
            children: [
              Text(network.isDiscovering ? "Searching..." : "Not searching"),
              const SizedBox(width: 8),
              Icon(
                network.isDiscovering ? Icons.radar : Icons.radar_outlined,
                color: network.isDiscovering ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveredSection(MeshNetworkService network) {
    return Container(
      color: Colors.blue.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nearby Devices", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: network.discoveredDevices.length,
              itemBuilder: (context, index) {
                final id = network.discoveredDevices[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    avatar: const Icon(Icons.bluetooth, size: 16),
                    label: Text("Connect $id"),
                    onPressed: () => network.requestConnection(id),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
