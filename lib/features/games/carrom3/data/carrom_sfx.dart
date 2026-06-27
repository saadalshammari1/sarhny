import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound-effects player for Carrom v3. Owns a small pool of
/// low-latency [AudioPlayer]s so rapid collisions can overlap without cutting
/// each other off. All playback is gated by [enabled] (wired to the mute
/// toggle). Assets live under `assets/audio/`.
class CarromSfx {
  CarromSfx._();
  static final CarromSfx instance = CarromSfx._();

  /// When false, every play() is a no-op (mute).
  bool enabled = true;

  static const int _poolSize = 4;
  final List<AudioPlayer> _pool = [];
  int _next = 0;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    for (var i = 0; i < _poolSize; i++) {
      final p = AudioPlayer();
      try {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
      } catch (_) {/* best-effort */}
      _pool.add(p);
    }
  }

  void _play(String asset, {double volume = 1.0}) {
    if (!enabled) return;
    try {
      if (_pool.isEmpty) {
        AudioPlayer().play(AssetSource(asset), volume: volume);
        return;
      }
      final p = _pool[_next];
      _next = (_next + 1) % _pool.length;
      p.play(AssetSource(asset), volume: volume);
    } catch (_) {/* never let SFX crash the game */}
  }

  void strike() => _play('audio/strike.wav');

  /// [intensity] scales the impact volume with how hard the collision was.
  void hit(double intensity) =>
      _play('audio/hit.wav', volume: (0.45 + 0.12 * intensity).clamp(0.3, 1.0));

  void pocket() => _play('audio/pocket.wav');

  void win() => _play('audio/win.wav');
}
