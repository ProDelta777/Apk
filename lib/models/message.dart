class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final int timestamp;
  final bool isSent;
  final bool isRead;
  final String type; // 'text', 'image', 'file', 'location'

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isSent,
    required this.isRead,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'isSent': isSent ? 1 : 0,
      'isRead': isRead ? 1 : 0,
      'type': type,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: map['timestamp'],
      isSent: map['isSent'] == 1,
      isRead: map['isRead'] == 1,
      type: map['type'],
    );
  }
}
