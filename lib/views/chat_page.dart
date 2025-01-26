import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/cloudinary_service.dart';
import 'package:chat_app/widgets/message_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
  bool isRecording = false;
  String? _currentUserId;
  String? _audioFilePath;
  bool isMessage = false;

  late final FlutterSoundRecorder _recorder;
  late final RecorderController _recorderController;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _recorderController = RecorderController();
    _initializeRecorder();
    _currentUserId = _authService.getCurrentUser()!.uid;

    // Listen to typing status
    _chatService.listenToTypingStatus(widget.receiver).listen((typingData) {
      setState(() {
        isOtherUserTyping = typingData['isTyping'] == true &&
            typingData['typingUserId'] != _currentUserId;
      });
    });
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(Duration(milliseconds: 50));
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _recorderController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        widget.receiver,
        _messageController.text,
        imageUrl: null,
      );
      _messageController.clear();
      _chatService.updateTypingStatus(widget.receiver, false);
    }
  }

  void _onMessageTyping() {
    final bool isTyping = _messageController.text.isNotEmpty;
    _chatService.updateTypingStatus(
      widget.receiver,
      isTyping,
      typingUserId: _currentUserId,
    );
    setState(() {
      isMessage = true;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      if (await file.exists()) {
        try {
          String imageUrl = await _cloudinaryService.uploadFile(file);
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

  Future<void> _startRecording() async {
    try {
      setState(() => isRecording = true);

      // Generate a file path for the recording
      final tempDir = await getTemporaryDirectory();
      _audioFilePath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Start the recorder
      await _recorder.startRecorder(
        toFile: _audioFilePath,
      );

      // Start the waveform animation
      _recorderController.record();
    } catch (e) {
      print('Error while starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() => isRecording = false);

      // Stop the recorder and waveform animation
      _recorderController.stop();
      await _recorder.stopRecorder();

      if (_audioFilePath != null) {
        String uploadedUrl =
            await _cloudinaryService.uploadFile(File(_audioFilePath!));
        if (uploadedUrl.isNotEmpty) {
          _chatService.sendMessage(widget.receiver, '', audioUrl: uploadedUrl);
        }
      }
    } catch (e) {
      print('Error while stopping recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getMessages(widget.receiver),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
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
                      audioUrl: message['audioUrl'] ?? '',
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
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: isRecording
                        ? AudioWaveforms(
                            size: Size(double.infinity, 40.0),
                            recorderController: _recorderController,
                            waveStyle: WaveStyle(
                              waveColor: Colors.blue,
                              extendWaveform: true,
                              showMiddleLine: false,
                            ),
                          )
                        : TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type here...',
                              filled: true,
                              fillColor: Colors.black12.withOpacity(0.05),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.attach_file,
                                  color: Colors.blue,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                            onChanged: (text) {
                              _onMessageTyping();
                            },
                          ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: isMessage
                          ? _sendMessage // Send message if typing
                          : (isRecording
                              ? _stopRecording
                              : _startRecording), // Record if not typing
                      icon: Icon(
                        isMessage
                            ? Icons.send // Send icon when typing
                            : (isRecording
                                ? Icons.stop
                                : Icons.mic), // Mic or Stop
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
