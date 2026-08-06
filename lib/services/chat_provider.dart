import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/contact.dart';
import 'database_helper.dart';
import 'crypto_service.dart';
import 'mesh_network_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final MeshNetworkService networkService;

  List<Contact> contacts = [];
  Map<String, List<Message>> chatHistories = {};
  String myId = const Uuid().v4();

  ChatProvider(this.networkService) {
    networkService.onMessageReceived = _handleIncomingMessage;
    _loadContacts();
  }

  CryptoService _getCryptoForContact(String contactId) {
     final combinedIds = [myId, contactId]..sort();
     final mockSharedSecret = combinedIds.join('_');
     return CryptoService.init(mockSharedSecret);
  }

  Future<void> _loadContacts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    contacts = List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> loadChatHistory(String contactId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'senderId = ? OR receiverId = ?',
      whereArgs: [contactId, contactId],
      orderBy: 'timestamp ASC'
    );
    chatHistories[contactId] = List.generate(maps.length, (i) => Message.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> sendMessage(String receiverId, String text, {String type = 'text'}) async {
    final msgId = const Uuid().v4();
    final message = Message(
      id: msgId,
      senderId: myId,
      receiverId: receiverId,
      content: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isSent: true,
      isRead: false,
      type: type,
    );

    final db = await _dbHelper.database;
    await db.insert('messages', message.toMap());

    if (chatHistories[receiverId] != null) {
      chatHistories[receiverId]!.add(message);
    } else {
      chatHistories[receiverId] = [message];
    }
    notifyListeners();

    final crypto = _getCryptoForContact(receiverId);
    final encryptedText = crypto.encryptMessage(text);

    final payload = "$myId|$msgId|$type|$encryptedText";

    if (networkService.connectedDevices.containsKey(receiverId)) {
        await networkService.sendMessage(receiverId, payload);
    } else {
        for (var connectedId in networkService.connectedDevices.keys) {
            await networkService.sendMessage(connectedId, "RELAY|$receiverId|$payload");
        }
    }
  }

  void _handleIncomingMessage(String endpointId, String payload) async {
    try {
      if (payload.startsWith("RELAY|")) {
         final parts = payload.split('|');
         if (parts.length >= 3) {
            final targetId = parts[1];
            final actualPayload = parts.sublist(2).join('|');
            if (targetId == myId) {
                _processDirectPayload(endpointId, actualPayload);
            } else if (networkService.connectedDevices.containsKey(targetId)) {
                await networkService.sendMessage(targetId, payload);
            }
         }
         return;
      }

      _processDirectPayload(endpointId, payload);

    } catch (e) {
      debugPrint("Error handling incoming message: \$e");
    }
  }

  void _processDirectPayload(String endpointId, String payload) async {
      final parts = payload.split('|');
      if (parts.length >= 4) {
        final senderId = parts[0];
        final msgId = parts[1];
        final type = parts[2];
        final encryptedText = parts.sublist(3).join('|');

        final crypto = _getCryptoForContact(senderId);
        final decryptedText = crypto.decryptMessage(encryptedText);

        final message = Message(
          id: msgId,
          senderId: senderId,
          receiverId: myId,
          content: decryptedText,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          isSent: false,
          isRead: false,
          type: type,
        );

        final db = await _dbHelper.database;
        await db.insert('messages', message.toMap());

        if (chatHistories[senderId] != null) {
          chatHistories[senderId]!.add(message);
        } else {
          chatHistories[senderId] = [message];
        }

        if (!contacts.any((c) => c.id == senderId)) {
            final newContact = Contact(id: senderId, name: "User $senderId", publicKey: "", lastSeen: DateTime.now().millisecondsSinceEpoch);
            await db.insert('contacts', newContact.toMap());
            contacts.add(newContact);
        }
        notifyListeners();
      }
  }
}
