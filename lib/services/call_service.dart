import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:friendly_chat/shared/constants.dart';

class CallService {
  static const String CHANNEL_PREFIX = 'friendlychat_';
  static const String CALLS_COLLECTION = 'calls';

  bool _isInCall = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  String? _currentChannel;
  String? _currentCallId;
  StreamController<CallState>? _callStateController;
  StreamSubscription<DocumentSnapshot>? _callDocSubscription;

  // Singleton instance
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  Stream<CallState> get callStateStream {
    _callStateController ??= StreamController<CallState>.broadcast();
    return _callStateController!.stream;
  }

  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;

  /// Request necessary permissions
  Future<void> _requestPermissions(bool isVideoCall) async {
    List<Permission> permissions = [Permission.microphone];
    if (isVideoCall) {
      permissions.add(Permission.camera);
    }
    await permissions.request();
  }

  /// Start a voice call
  Future<void> startVoiceCall(String friendId) async {
    if (_isInCall) return;

    await _requestPermissions(false);
    
    String channelName = _generateChannelName(friendId);
    _isInCall = true;
    _currentChannel = channelName;
    _isVideoEnabled = false;
    
    // Create call document in Firestore
    await _createCallDocument(friendId, false);
    
    // Notify listeners that call has started
    _callStateController?.add(CallState.joined(null));
  }

  /// Start a video call
  Future<void> startVideoCall(String friendId) async {
    if (_isInCall) return;

    await _requestPermissions(true);
    
    String channelName = _generateChannelName(friendId);
    _isInCall = true;
    _currentChannel = channelName;
    _isVideoEnabled = true;
    
    // Create call document in Firestore
    await _createCallDocument(friendId, true);
    
    // Notify listeners that call has started
    _callStateController?.add(CallState.joined(null));
  }

  /// Create a call document in Firestore
  Future<void> _createCallDocument(String friendId, bool isVideo) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final callDoc = await FirebaseFirestore.instance.collection(CALLS_COLLECTION).add({
        'callerId': currentUser.uid,
        'calleeId': friendId,
        'channelName': _generateChannelName(friendId),
        'isVideo': isVideo,
        'status': 'initiated',
        'createdAt': FieldValue.serverTimestamp(),
        'startedAt': null,
        'endedAt': null,
        'duration': 0,
      });

      _currentCallId = callDoc.id;
      
      // Listen for call status changes
      _listenToCallStatus();
    } catch (e) {
      print('Error creating call document: $e');
      _callStateController?.add(CallState.error(0, 'Failed to initiate call'));
    }
  }

  /// Listen to call status changes in Firestore
  void _listenToCallStatus() {
    if (_currentCallId == null) return;
    
    _callDocSubscription?.cancel();
    _callDocSubscription = FirebaseFirestore.instance
        .collection(CALLS_COLLECTION)
        .doc(_currentCallId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;
      
      final status = data['status'] as String?;
      
      switch (status) {
        case 'accepted':
          _callStateController?.add(CallState.joined(null));
          break;
        case 'rejected':
        case 'ended':
          _callStateController?.add(const CallLeft());
          break;
        case 'busy':
          _callStateController?.add(CallError(1, 'User is busy'));
          break;
      }
    });
  }

  /// Accept an incoming call
  Future<void> acceptCall(String callId) async {
    try {
      await FirebaseFirestore.instance.collection(CALLS_COLLECTION).doc(callId).update({
        'status': 'accepted',
        'startedAt': FieldValue.serverTimestamp(),
      });
      
      // Get call details
      final callDoc = await FirebaseFirestore.instance.collection(CALLS_COLLECTION).doc(callId).get();
      final data = callDoc.data() as Map<String, dynamic>?;
      
      if (data != null) {
        _isInCall = true;
        _currentCallId = callId;
        _currentChannel = data['channelName'] as String?;
        _isVideoEnabled = data['isVideo'] as bool? ?? false;
        _listenToCallStatus();
      }
    } catch (e) {
      print('Error accepting call: $e');
    }
  }

  /// Reject an incoming call
  Future<void> rejectCall(String callId) async {
    try {
      await FirebaseFirestore.instance.collection(CALLS_COLLECTION).doc(callId).update({
        'status': 'rejected',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error rejecting call: $e');
    }
  }

  /// End the current call
  Future<void> endCall() async {
    if (_currentCallId != null) {
      try {
        await FirebaseFirestore.instance.collection(CALLS_COLLECTION).doc(_currentCallId).update({
          'status': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error ending call: $e');
      }
    }
    
    _isInCall = false;
    _currentChannel = null;
    _currentCallId = null;
    _callDocSubscription?.cancel();
    _callStateController?.add(const CallLeft());
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    _callStateController?.add(MuteChanged(_isMuted));
  }

  /// Toggle video state
  Future<void> toggleVideo() async {
    _isVideoEnabled = !_isVideoEnabled;
    _callStateController?.add(VideoChanged(_isVideoEnabled));
  }

  /// Generate a unique channel name for the call
  String _generateChannelName(String friendId) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Create a consistent channel name regardless of who initiates the call
    List<String> userIds = [currentUserId, friendId]..sort();
    return '$CHANNEL_PREFIX${userIds.join('_')}';
  }

  /// Get incoming calls for current user
  Stream<QuerySnapshot> getIncomingCalls() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }
    
    return FirebaseFirestore.instance
        .collection(CALLS_COLLECTION)
        .where('calleeId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'initiated')
        .snapshots();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _callStateController?.close();
    await _callDocSubscription?.cancel();
    _isInCall = false;
    _currentChannel = null;
    _currentCallId = null;
  }
}

/// Call state events
abstract class CallState {
  const CallState();

  factory CallState.joined(dynamic connection) = CallJoined;
  factory CallState.userJoined(int uid) = UserJoined;
  factory CallState.userLeft(int uid) = UserLeft;
  factory CallState.left() = CallLeft;
  factory CallState.muteChanged(bool isMuted) = MuteChanged;
  factory CallState.videoChanged(bool isVideoEnabled) = VideoChanged;
  factory CallState.error(int errorCode, String message) = CallError;
}

class CallJoined extends CallState {
  final dynamic connection;
  const CallJoined(this.connection);
}

class UserJoined extends CallState {
  final int uid;
  const UserJoined(this.uid);
}

class UserLeft extends CallState {
  final int uid;
  const UserLeft(this.uid);
}

class CallLeft extends CallState {
  const CallLeft();
}

class MuteChanged extends CallState {
  final bool isMuted;
  const MuteChanged(this.isMuted);
}

class VideoChanged extends CallState {
  final bool isVideoEnabled;
  const VideoChanged(this.isVideoEnabled);
}

class CallError extends CallState {
  final int errorCode;
  final String message;
  const CallError(this.errorCode, this.message);
}