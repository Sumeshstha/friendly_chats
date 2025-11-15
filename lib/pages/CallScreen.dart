import 'dart:async';
import 'package:flutter/material.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import 'package:friendly_chat/services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String friendName;
  final String friendId;
  final bool isVideoCall;

  const CallScreen({
    Key? key,
    required this.friendName,
    required this.friendId,
    required this.isVideoCall,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _isConnecting = true;
  Timer? _timer;
  int _callDuration = 0;
  StreamSubscription<CallState>? _callStateSubscription;

  @override
  void initState() {
    super.initState();
    _startCall();
    _startTimer();
    _listenToCallState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _callStateSubscription?.cancel();
    _callService.endCall();
    _callService.dispose();
    super.dispose();
  }

  void _listenToCallState() {
    _callStateSubscription = _callService.callStateStream.listen((state) {
      if (state is MuteChanged) {
        setState(() {
          _isMuted = state.isMuted;
        });
      } else if (state is VideoChanged) {
        setState(() {
          _isVideoEnabled = state.isVideoEnabled;
        });
      } else if (state is CallLeft) {
        // Call ended, navigate back
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (state is CallError) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call error: ${state.message}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          Navigator.pop(context);
        }
      } else if (state is CallJoined) {
        // Call connected
        setState(() {
          _isConnecting = false;
        });
      }
    });
  }

  void _startCall() async {
    try {
      if (widget.isVideoCall) {
        await _callService.startVideoCall(widget.friendId);
      } else {
        await _callService.startVoiceCall(widget.friendId);
      }
    } catch (e) {
      print('Error starting call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start call: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with friend info
            _buildHeader(),
            
            // Video/Avatar area
            Expanded(
              child: widget.isVideoCall 
                ? _buildVideoView() 
                : _buildVoiceView(),
            ),
            
            // Call controls
            _buildCallControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _callService.endCall();
              Navigator.pop(context);
            },
          ),
          Column(
            children: [
              Text(
                widget.friendName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _isConnecting ? 'Connecting...' : _formatDuration(_callDuration),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Spacer for symmetry
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    return Center(
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnecting ? Icons.link : Icons.videocam,
              size: 64,
              color: _isConnecting ? Colors.orange : Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              _isConnecting ? 'Connecting to ${widget.friendName}...' : widget.friendName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              widget.friendName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.friendName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isConnecting ? 'Connecting...' : 'On call',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: 'Mute',
                onPressed: _toggleMute,
                active: _isMuted,
              ),
              if (widget.isVideoCall)
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: 'Video',
                  onPressed: _toggleVideo,
                  active: !_isVideoEnabled,
                ),
              _buildControlButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                label: 'Speaker',
                onPressed: _toggleSpeaker,
                active: _isSpeakerOn,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // End call button
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool active = false,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: active ? AppTheme.errorColor : Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: AppTheme.errorColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.call_end, color: Colors.white, size: 32),
        onPressed: () {
          _callService.endCall();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleMute() async {
    await _callService.toggleMute();
  }

  void _toggleVideo() async {
    await _callService.toggleVideo();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }
}