import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/audio_controller.dart';
import '../services/veterinary_service.dart';
import '../../../core/services/file_storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}


class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isVoiceMode = true;
  
  final FileStorageService _fileService = FileStorageService();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hello! I'm PawPath AI. Describe your pet's symptoms, and I'll help you triage the situation.",
      isUser: false,
    ));
  }
  
  // Audio Listener ... (Same as before)
  void _listenToAudioState() {
     ref.listen(audioControllerProvider, (previous, next) {
      if (next.status == AudioState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}'), backgroundColor: Colors.red),
        );
      }
      if (next.status == AudioState.listening) {
        if (_textController.text != next.text) {
          _textController.text = next.text;
        }
      }
      if (previous?.status == AudioState.listening && next.status == AudioState.processing) {
        _handleSubmitted(next.text);
      }
    });
  }

  void _pickImage() async {
    final path = await _fileService.pickImage(ImageSource.camera); // Could allow gallery choice too
    if (path != null) {
      setState(() {
        _selectedImagePath = path;
        _isVoiceMode = false; // Switch to text mode to visually confirm image + text
      });
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty && _selectedImagePath == null) return;

    final audioCtrl = ref.read(audioControllerProvider.notifier);
    
    _textController.clear();
    final imageToSend = _selectedImagePath; // Capture current image
    setState(() {
      _selectedImagePath = null; // Clear after sending
      _messages.add(ChatMessage(text: text, isUser: true, imagePath: imageToSend));
      _isTyping = true;
    });
    _scrollToBottom();

    // Mock Pet Profile
    final petProfile = {
      'name': 'Buddy',
      'breed': 'Golden Retriever',
      'age': 2,
      'weight': '70lbs',
      'idNumber': 'K9-Mock'
    };

    // Get AI Response
    final vetService = ref.read(veterinaryServiceProvider);
    final response = await vetService.analyzeSymptoms(
      symptoms: text,
      petProfile: petProfile,
      imagePath: imageToSend,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: response, isUser: false));
      });
      _scrollToBottom();
      
      if (_isVoiceMode) {
        audioCtrl.speak(response);
      }
    }
  }

  // ... (ScrollToBottom, ToggleVoice, BuildContext same)
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToAudioState();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Triage Assistant', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic),
            onPressed: _toggleVoiceMode,
            tooltip: _isVoiceMode ? 'Switch to Text' : 'Switch to Voice',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return const _TypingIndicator();
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_selectedImagePath != null)
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: FileImage(File(_selectedImagePath!)), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImagePath = null),
                    child: const CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.close, size: 16)),
                  ),
                ),
              ),
            _isVoiceMode ? _buildVoiceInput() : _buildTextInput(),
          ],
        ),
      ),
    );
  }

  // ... _buildVoiceInput updated logic for passing image? Voice usually just text. 
  // Let's assume sending image via Voice mode triggers immediate send with text transcript.
  // Ideally, add a check if image is there.
  
  Widget _buildVoiceInput() {
     final audioState = ref.watch(audioControllerProvider);
    final audioCtrl = ref.read(audioControllerProvider.notifier);
    final isListening = audioState.status == AudioState.listening;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_textController.text.isNotEmpty && isListening)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _textController.text,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Add Camera Button to Voice Mode too?
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 30),
              onPressed: _pickImage,
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTapDown: (_) => audioCtrl.startListening(),
              onTapUp: (_) => audioCtrl.stopListening(),
              onTap: isListening ? audioCtrl.stopListening : audioCtrl.startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: isListening ? Colors.redAccent : const Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isListening ? Colors.redAccent : const Color(0xFF4A90E2)).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 50), // Balance the row
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isListening ? "Listening..." : "Tap to Speak",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.grey),
          onPressed: _pickImage,
        ),
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Describe symptoms...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              fillColor: Colors.grey[100],
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: _handleSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          onPressed: () => _handleSubmitted(_textController.text),
          backgroundColor: const Color(0xFF4A90E2),
          elevation: 0,
          mini: true,
          child: const Icon(Icons.send, color: Colors.white),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;

  ChatMessage({required this.text, required this.isUser, this.imagePath});
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [
             if (!message.isUser) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(message.imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            Text(
              message.text,
              style: GoogleFonts.openSans(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               _Dot(delay: 0),
               _Dot(delay: 1),
               _Dot(delay: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;

  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(widget.delay * 0.2, 1.0 + widget.delay * 0.2, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        height: 8,
        width: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
