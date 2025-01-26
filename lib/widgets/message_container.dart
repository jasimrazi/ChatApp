import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart';

class MessageContainer extends StatefulWidget {
  final String? message;
  final String sender;
  final String? imageUrl;
  final String? audioUrl;
  final Timestamp? timestamp;
  final String currentUserId;

  const MessageContainer({
    Key? key,
    required this.sender,
    this.message,
    this.imageUrl,
    this.audioUrl,
    this.timestamp,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _MessageContainerState createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {
  late FlutterSoundPlayer _audioPlayer;

  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();

    _audioPlayer.openPlayer().then((_) {
      _audioPlayer.setSubscriptionDuration(Duration(milliseconds: 50));
      _audioPlayer.onProgress!.listen((event) {
        if (event.duration.inMilliseconds > 0) {
          setState(() {
            _progress =
                event.position.inMilliseconds / event.duration.inMilliseconds;

            // Add a check to reset when audio is complete
            if (_progress >= 1.0) {
              _progress = 0.0;
              _isPlaying = false;
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }

  void _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pausePlayer();
        setState(() {
          _isPlaying = false;
        });
      } else {
        if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
          await _audioPlayer.startPlayer(
            fromURI: widget.audioUrl,
            codec: Codec.aacADTS,
            whenFinished: () {
              setState(() {
                _isPlaying = false;
                _progress = 0.0; // Explicitly reset progress
              });
            },
          );
          setState(() {
            _isPlaying = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid audio URL')),
          );
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSender = widget.sender == widget.currentUserId;

    // Format the timestamp
    String formattedTime = 'No timestamp';
    if (widget.timestamp != null) {
      DateTime dateTime = widget.timestamp!.toDate();
      formattedTime = DateFormat('h:mm a').format(dateTime);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender) SizedBox(width: 40), // Padding for receiver
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    offset: Offset(0, 3),
                  ),
                ],
                color: isSender ? Color(0xffdcebfa) : Color(0xffe6f5ff),
                borderRadius: BorderRadius.only(
                  topLeft: isSender ? Radius.circular(20) : Radius.circular(5),
                  topRight: isSender ? Radius.circular(5) : Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14)),
                                child: IconButton(
                                  icon: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                  onPressed: _togglePlayPause,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: Colors.white,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else if (widget.imageUrl != null &&
                      widget.imageUrl!.isNotEmpty)
                    Image.network(
                      widget.imageUrl!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  else if (widget.message != null && widget.message!.isNotEmpty)
                    Text(
                      widget.message!,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSender) SizedBox(width: 40), // Padding for sender
        ],
      ),
    );
  }
}
