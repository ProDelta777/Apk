import 'dart:convert';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:flutter/foundation.dart';

class MeshNetworkService extends ChangeNotifier {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  String _userName = 'User';
  final Map<String, String> connectedDevices = {};
  final List<String> discoveredDevices = [];
  bool isAdvertising = false;
  bool isDiscovering = false;

  Function(String endpointId, String payload)? onMessageReceived;

  Future<void> init(String userName) async {
    _userName = userName;
  }

  Future<void> startAdvertising() async {
    try {
      bool a = await Nearby().startAdvertising(
        _userName,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      isAdvertising = a;
      notifyListeners();
    } catch (e) {
      debugPrint("Advertising error: $e");
    }
  }

  Future<void> stopAdvertising() async {
    await Nearby().stopAdvertising();
    isAdvertising = false;
    notifyListeners();
  }

  Future<void> startDiscovery() async {
    try {
      bool a = await Nearby().startDiscovery(
        _userName,
        strategy,
        onEndpointFound: (endpointId, endpointName, serviceId) {
          if (!discoveredDevices.contains(endpointId)) {
            discoveredDevices.add(endpointId);
            notifyListeners();
          }
        },
        onEndpointLost: (endpointId) {
          discoveredDevices.remove(endpointId);
          notifyListeners();
        },
      );
      isDiscovering = a;
      notifyListeners();
    } catch (e) {
      debugPrint("Discovery error: $e");
    }
  }

  Future<void> stopDiscovery() async {
    await Nearby().stopDiscovery();
    isDiscovering = false;
    discoveredDevices.clear();
    notifyListeners();
  }

  Future<void> requestConnection(String endpointId) async {
    try {
      await Nearby().requestConnection(
        _userName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      debugPrint("Request connection error: $e");
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) async {
    // Auto accept connection for prototype
    await Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES) {
          String data = utf8.decode(payload.bytes!);
          if (onMessageReceived != null) {
            onMessageReceived!(endpointId, data);
          }
        }
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      connectedDevices[endpointId] = "Connected Node";
      notifyListeners();
    } else {
      connectedDevices.remove(endpointId);
      notifyListeners();
    }
  }

  void _onDisconnected(String endpointId) {
    connectedDevices.remove(endpointId);
    notifyListeners();
  }

  Future<void> sendMessage(String endpointId, String message) async {
    try {
      await Nearby().sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(message)));
    } catch (e) {
      debugPrint("Send message error: $e");
    }
  }
}
