import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/cloudinary_service.dart';
import 'package:chat_app/widgets/message_container.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String name;
  final String receiver;

  ChatPage({required this.name, required this.receiver});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool isOtherUserTyping = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.getCurrentUser()!.uid;

    print('Current user: ${_currentUserId}');

    // Listen to typing status
    _chatService.listenToTypingStatus(widget.receiver).listen((typingData) {
      setState(() {
        // Check if the typing user is different from the current user
        isOtherUserTyping = typingData['isTyping'] == true &&
            typingData['typingUserId'] != _currentUserId;
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        widget.receiver,
        _messageController.text,
        imageUrl: null,
      );
      _messageController.clear();
      // Reset typing status when message is sent
      _chatService.updateTypingStatus(widget.receiver, false,);
    }
  }

  void _onMessageTyping() {
    final bool isTyping = _messageController.text.isNotEmpty;
    _chatService.updateTypingStatus(widget.receiver, isTyping,
        typingUserId: _currentUserId);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      if (await file.exists()) {
        try {
          String imageUrl = await _cloudinaryService.uploadImage(file);
          if (imageUrl.isNotEmpty) {
            _chatService.sendMessage(widget.receiver, '', imageUrl: imageUrl);
          } else {
            print('Error: Image URL is empty.');
          }
        } catch (e) {
          print('Error uploading image: $e');
        }
      } else {
        print('File does not exist at path: ${image.path}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getMessages(widget.receiver),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                List<Map<String, dynamic>> messages = snapshot.data!;
                return ListView.builder(
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageContainer(
                      message: message['message'],
                      imageUrl: message['imageUrl'] ?? '',
                      sender: message['sender'],
                      timestamp: message['timestamp'],
                      currentUserId: _currentUserId!,
                    );
                  },
                );
              },
            ),
          ),
          if (isOtherUserTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${widget.name} is typing...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                    onChanged: (text) {
                      _onMessageTyping();
                    },
                  ),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  color: Colors.deepPurple,
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
