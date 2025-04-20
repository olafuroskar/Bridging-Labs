import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.playerStateStream.listen(_onPlayerState);

    mediaItem.add(
      MediaItem(
        id: 'silent-audio',
        title: 'Keeping LSL alive...',
        artist: 'Sensors Flutter',
        duration: Duration(seconds: 1), // doesn't really matter
      ),
    );

    await _player.setAsset('assets/1-second-of-silence.mp3');
    await _player.setLoopMode(LoopMode.one);
  }

  // The most common callbacks:
  @override
  Future<void> play() {
    return _player.play();
  }

  @override
  Future<void> pause() {
    // Would be nice to be able to send markers via the audio controls
    return _player.pause();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  void _onPlayerState(PlayerState state) {
    // Event markers could be sent from here
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
