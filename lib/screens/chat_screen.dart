import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _currentlyPlayingMessageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadChatHistory(widget.contactId);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
       if (mounted) {
          setState(() { _currentlyPlayingMessageId = null; });
       }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
        );
    }
  }

  void _sendMessage({String? overrideText, String type = 'text'}) {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(widget.contactId, text, type: type);
    if (overrideText == null) _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
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

  Future<void> _startRecording() async {
     if (await _audioRecorder.hasPermission()) {
         setState(() => _isRecording = true);
         final tempDir = Directory.systemTemp;
         final tempFile = File('${tempDir.path}/temp_audio.m4a');
         await _audioRecorder.start(const RecordConfig(), path: tempFile.path);
     }
  }

  Future<void> _stopRecording() async {
     final path = await _audioRecorder.stop();
     setState(() => _isRecording = false);
     if (path != null) {
         final bytes = await File(path).readAsBytes();
         final base64Audio = base64Encode(bytes);
         _sendMessage(overrideText: base64Audio, type: 'audio');
     }
  }

  Future<void> _playAudio(String messageId, String base64Data) async {
     if (_currentlyPlayingMessageId == messageId) {
         await _audioPlayer.stop();
         setState(() => _currentlyPlayingMessageId = null);
     } else {
         final bytes = base64Decode(base64Data);
         final tempDir = Directory.systemTemp;
         final tempFile = File('${tempDir.path}/play_$messageId.m4a');
         await tempFile.writeAsBytes(bytes);

         await _audioPlayer.play(DeviceFileSource(tempFile.path));
         setState(() => _currentlyPlayingMessageId = messageId);
     }
  }

  void _showDeleteDialog(String messageId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).deleteMessage(widget.contactId, messageId);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.chatHistories[widget.contactId] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.contactName[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Text(widget.contactName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
               _sendMessage(overrideText: "Location: 37.422, -122.084", type: 'location');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blue.withValues(alpha: 0.05),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
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
                          contentWidget = ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(base64Decode(message.content), height: 200, width: 200, fit: BoxFit.cover),
                          );
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
                  } else if (message.type == 'audio') {
                      final isPlaying = _currentlyPlayingMessageId == message.id;
                      contentWidget = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              IconButton(
                                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, color: isMe ? Colors.white : Colors.black87),
                                  onPressed: () => _playAudio(message.id, message.content),
                              ),
                              Text("Voice Note", style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                          ]
                      );
                  }

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress: isMe ? () => _showDeleteDialog(message.id) : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                          ),
                          boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            contentWidget,
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10),
                                ),
                                if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                        Icons.done_all,
                                        size: 14,
                                        color: message.isRead ? Colors.blue.shade200 : Colors.white70
                                    ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)
                  ]
                ),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.add, color: Colors.blue), onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (_) => SizedBox(
                                height: 120,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                        _bottomSheetIcon(Icons.image, Colors.purple, "Gallery", _pickImage),
                                        _bottomSheetIcon(Icons.insert_drive_file, Colors.orange, "Document", _pickFile),
                                        _bottomSheetIcon(Icons.location_on, Colors.green, "Location", () {
                                            Navigator.pop(context);
                                            _sendMessage(overrideText: "Location: 37.422, -122.084", type: 'location');
                                        }),
                                    ]
                                )
                            )
                        );
                    }),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressUp: _stopRecording,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                child: IconButton(
                  icon: Icon(_isRecording ? Icons.mic : Icons.send, color: Colors.white),
                  onPressed: () {
                      if (!_isRecording && _messageController.text.isNotEmpty) {
                          _sendMessage();
                      }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetIcon(IconData icon, Color color, String label, VoidCallback onTap) {
      return InkWell(
          onTap: () {
              Navigator.pop(context);
              onTap();
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  CircleAvatar(radius: 26, backgroundColor: color, child: Icon(icon, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(label),
              ]
          ),
      );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
