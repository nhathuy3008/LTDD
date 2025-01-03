import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Models/Song.dart'; // Nhập mô hình Song

class PlaySongScreen extends StatefulWidget {
  final List<Song> playlist; // Danh sách bài hát
  final int currentSongIndex; // Chỉ số bài hát hiện tại

  PlaySongScreen({
    required this.playlist,
    required this.currentSongIndex, // Nhận chỉ số bài hát hiện tại
  });

  @override
  _PlaySongScreenState createState() => _PlaySongScreenState();
}

class _PlaySongScreenState extends State<PlaySongScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLooping = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  late AnimationController _controller;
  late int _currentSongIndex;

  @override
  void initState() {
    super.initState();
    _currentSongIndex = widget.currentSongIndex; // Sử dụng chỉ số bài hát được truyền vào
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_){
      if(_isLooping){
        _playAudio();
      }else{
        _nextSong();
      }
    });
    _playAudio(); // Phát bài hát khi khởi động
  }

  void _playAudio() async {
    await _audioPlayer.play(UrlSource(widget.playlist[_currentSongIndex].url));
    setState(() {
      _isPlaying = true;
    });
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void _nextSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % widget.playlist.length;
      _playAudio(); // Phát bài hát mới
    });
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + widget.playlist.length) % widget.playlist.length;
      _playAudio(); // Phát bài hát mới
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[_currentSongIndex]; // Lấy bài hát hiện tại

    return Scaffold(
      appBar: AppBar(title: Text(currentSong.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * 3.14159265359,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(currentSong.image ?? 'https://example.com/default_image.jpg'), // Cung cấp giá trị mặc định
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text('Đang phát: ${currentSong.name}'),
            Text('Nghệ sĩ: ${currentSong.artist}'),
            Text('${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}'),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (value) {
                _seekTo(value);
              },
              onChangeEnd: (value) {
                _seekTo(value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _previousSong,
                  child: Icon(Icons.skip_previous, size: 32),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: _isPlaying ? _pauseAudio : _playAudio,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: _nextSong,
                  child: Icon(Icons.skip_next, size: 32),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _toggleLoop,
              child: Icon(Icons.replay, size: 32, color: _isLooping ? Colors.orange : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}