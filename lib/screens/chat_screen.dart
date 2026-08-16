import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  String userName = "User_${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";

  bool isDiscovering = false;
  bool isAdvertising = false;

  String? connectedEndpointId;
  String? connectedEndpointName;

  List<Map<String, String>> messages = [];
  final TextEditingController _msgController = TextEditingController();

  Map<String, String> discoveredDevices = {}; // id -> name

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();
  }

  void _startAdvertising() async {
    try {
      bool a = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            setState(() {
              connectedEndpointId = id;
              isAdvertising = false;
              isDiscovering = false;
            });
            Nearby().stopAdvertising();
            Nearby().stopDiscovery();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection failed: $status')));
          }
        },
        onDisconnected: (id) {
          setState(() {
            connectedEndpointId = null;
            connectedEndpointName = null;
            messages.add({'sender': 'System', 'msg': 'Disconnected.'});
          });
        },
      );
      setState(() {
        isAdvertising = a;
      });
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot start advertising: $exception')));
    }
  }

  void _startDiscovery() async {
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          setState(() {
            discoveredDevices[id] = name;
          });
        },
        onEndpointLost: (id) {
          setState(() {
            discoveredDevices.remove(id);
          });
        },
      );
      setState(() {
        isDiscovering = a;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot start discovery: $e')));
    }
  }

  void _onConnectionInit(String id, ConnectionInfo info) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text("Connect to ${info.endpointName}?"),
          content: Text("Authentication token: ${info.authenticationToken}"),
          actions: <Widget>[
            TextButton(
              child: const Text("REJECT"),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Nearby().rejectConnection(id);
                } catch (e) {}
              },
            ),
            FilledButton(
              child: const Text("ACCEPT"),
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  connectedEndpointName = info.endpointName;
                });
                try {
                  await Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes!);
                        setState(() {
                          messages.add({'sender': connectedEndpointName ?? endid, 'msg': str});
                        });
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {},
                  );
                } catch (e) {}
              },
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() {
    if (connectedEndpointId != null && _msgController.text.isNotEmpty) {
      Nearby().sendBytesPayload(
        connectedEndpointId!,
        Uint8List.fromList(_msgController.text.codeUnits),
      );
      setState(() {
        messages.add({'sender': 'Me', 'msg': _msgController.text});
        _msgController.clear();
      });
    }
  }

  void _disconnect() async {
    if (connectedEndpointId != null) {
      await Nearby().disconnectFromEndpoint(connectedEndpointId!);
      setState(() {
        connectedEndpointId = null;
        connectedEndpointName = null;
        messages.clear();
      });
    }
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    setState(() {
      isAdvertising = false;
      isDiscovering = false;
      discoveredDevices.clear();
    });
  }

  @override
  void dispose() {
    _disconnect();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Comms'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (connectedEndpointId != null)
            IconButton(
              icon: const Icon(Icons.link_off, color: Colors.red),
              onPressed: _disconnect,
              tooltip: 'Disconnect',
            )
        ],
      ),
      body: connectedEndpointId == null ? _buildLobby(theme) : _buildChat(theme),
    );
  }

  Widget _buildLobby(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.bluetooth_connected, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'CONNECT VIA BLUETOOTH/WIFI DIRECT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'No internet required. Find nearby devices running OFFGRID to establish a secure P2P chat link.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isAdvertising ? null : _startAdvertising,
                  icon: isAdvertising ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.broadcast_on_personal),
                  label: Text(isAdvertising ? 'Hosting...' : 'Host Chat'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isDiscovering ? null : _startDiscovery,
                  icon: isDiscovering ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                  label: Text(isDiscovering ? 'Scanning...' : 'Find Chat'),
                ),
              ),
            ],
          ),
          if (isAdvertising || isDiscovering)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextButton(
                onPressed: () {
                  Nearby().stopAdvertising();
                  Nearby().stopDiscovery();
                  setState(() {
                    isAdvertising = false;
                    isDiscovering = false;
                    discoveredDevices.clear();
                  });
                },
                child: const Text('Cancel / Stop Radio', style: TextStyle(color: Colors.red)),
              ),
            ),

          const SizedBox(height: 24),
          if (discoveredDevices.isNotEmpty) ...[
            Text('Found Devices:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: discoveredDevices.length,
                itemBuilder: (context, index) {
                  String id = discoveredDevices.keys.elementAt(index);
                  String name = discoveredDevices[id]!;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: Text(name),
                      subtitle: Text('ID: $id'),
                      trailing: FilledButton(
                        onPressed: () async {
                          try {
                            await Nearby().requestConnection(
                              userName,
                              id,
                              onConnectionInitiated: _onConnectionInit,
                              onConnectionResult: (id, status) {
                                if (status == Status.CONNECTED) {
                                  setState(() {
                                    connectedEndpointId = id;
                                    isAdvertising = false;
                                    isDiscovering = false;
                                  });
                                  Nearby().stopDiscovery();
                                  Nearby().stopAdvertising();
                                }
                              },
                              onDisconnected: (id) {
                                setState(() {
                                  connectedEndpointId = null;
                                  connectedEndpointName = null;
                                });
                              },
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        },
                        child: const Text('Connect'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildChat(ThemeData theme) {
    return Column(
      children: [
        Container(
          color: theme.colorScheme.primaryContainer,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.lock, size: 16, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                'Connected to $connectedEndpointName',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg['sender'] == 'Me';
              final isSystem = msg['sender'] == 'System';

              if (isSystem) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(msg['msg']!, style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                  ),
                );
              }

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? theme.colorScheme.primary : theme.cardColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isMe ? const Radius.circular(0) : null,
                      bottomLeft: !isMe ? const Radius.circular(0) : null,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        Text(
                          msg['sender']!,
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        msg['msg']!,
                        style: TextStyle(color: isMe ? theme.colorScheme.onPrimary : null),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  elevation: 0,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
