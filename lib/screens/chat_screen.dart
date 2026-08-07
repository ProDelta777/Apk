import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String contactId;
  final String contactName;

  const ChatScreen({super.key, required this.contactId, required this.contactName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadChatHistory(widget.contactId);
    });
  }

  void _sendMessage({String? overrideText, String type = 'text'}) {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(widget.contactId, text, type: type);
    if (overrideText == null) _messageController.clear();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      _sendMessage(overrideText: base64Image, type: 'image');
    }
  }

  Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
          final file = File(result.files.single.path!);
          final bytes = await file.readAsBytes();
          final base64File = base64Encode(bytes);
          final fileName = result.files.single.name;
          _sendMessage(overrideText: "$fileName|$base64File", type: 'file');
      }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.chatHistories[widget.contactId] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
               _sendMessage(overrideText: "Location: 37.422, -122.084", type: 'location');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.isSent;

                Widget contentWidget = Text(
                    message.content,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
                );

                if (message.type == 'image') {
                    try {
                        contentWidget = Image.memory(base64Decode(message.content), height: 200, fit: BoxFit.cover);
                    } catch (e) {
                        contentWidget = const Icon(Icons.broken_image);
                    }
                } else if (message.type == 'file') {
                    final parts = message.content.split('|');
                    final name = parts.isNotEmpty ? parts[0] : "File";
                    contentWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const Icon(Icons.insert_drive_file, color: Colors.white),
                            const SizedBox(width: 8),
                            Flexible(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))),
                        ]
                    );
                } else if (message.type == 'location') {
                    contentWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const Icon(Icons.map, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        ]
                    );
                }

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        contentWidget,
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.photo), onPressed: _pickImage),
            IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
