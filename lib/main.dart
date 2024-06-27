import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Bubble',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Chat Bubble'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  List<ChatMessage> messages = [];
  bool isRecording = false;
  String? recordedFilePath;
  // final Record _record = Record();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ...messages.map((message) => _buildMessageBubble(message)),
                DateChip(
                  date: now,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          MessageBar(
            onSend: (text) {
              _addTextMessage(text);
            },
            actions: [
              InkWell(
                onTap: _toggleRecording,
                child: const Icon(
                  Icons.mic,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: InkWell(
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.green,
                    size: 24,
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return BubbleNormal(
          text: message.content,
          isSender: message.isSender,
          color: message.isSender ? const Color(0xFFE8E8EE) : const Color(0xFF1B97F3),
          tail: true,
          sent: true,
        );
      case MessageType.audio:
        return BubbleNormalAudio(
          color: const Color(0xFFE8E8EE),
          duration: message.duration.inSeconds.toDouble(),
          position: 0,
          isPlaying: false,
          isLoading: false,
          isPause: false,
          onSeekChanged: (value) {},
          onPlayPauseButtonClick: () => _playRecordedAudio(message.content),
          sent: true,
        );
      default:
        return Container();
    }
  }

  void _addTextMessage(String text) {
    setState(() {
      messages.add(ChatMessage(
        type: MessageType.text,
        content: text,
        isSender: true,
      ));
    });
  }

  void _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      final path = '';
      setState(() {
        isRecording = false;
        recordedFilePath = path;
        if (path != null) {
          messages.add(ChatMessage(
            type: MessageType.audio,
            content: path,
            isSender: true,
            duration: Duration(seconds: 0), // Placeholder duration
          ));
        }
      });
    } else {
      // Start recording
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      // await _record.start(
      //   path: path,
      //   encoder: AudioEncoder.AAC,
      //   bitRate: 128000,
      //   samplingRate: 44100,
      // );
      setState(() {
        isRecording = true;
        recordedFilePath = null;
      });
    }
  }

  void _playRecordedAudio(String path) async {
    if (path.isNotEmpty) {
      await audioPlayer.play(DeviceFileSource(path));
    }
  }
}

class ChatMessage {
  final MessageType type;
  final String content;
  final bool isSender;
  final Duration duration;

  ChatMessage({
    required this.type,
    required this.content,
    required this.isSender,
    this.duration = Duration.zero,
  });
}

enum MessageType { text, audio }
