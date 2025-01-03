import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Models/Song.dart';
import '../Services/favorite_service.dart';

class PlaySongScreen extends StatefulWidget {
  final List<Song> playlist;
  final int currentSongIndex;
  final String accountId;

  PlaySongScreen({
    required this.playlist,
    required this.currentSongIndex,
    required this.accountId,
  });

  @override
  _PlaySongScreenState createState() => _PlaySongScreenState();
}

class _PlaySongScreenState extends State<PlaySongScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FavoriteService _favoriteService = FavoriteService();

  bool _isPlaying = false;
  bool _isLooping = false; // Trạng thái phát lại
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _likeCount = 0;
  bool _isLiked = false;

  late AnimationController _controller;
  late int _currentSongIndex;

  @override
  void initState() {
    super.initState();
    _currentSongIndex = widget.currentSongIndex;
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

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

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isLooping) {
        _playAudio();
      } else {
        _nextSong();
      }
    });

    _playAudio();
    _fetchLikeCount();
  }

  void _fetchLikeCount() async {
    try {
      int likeCount = await _favoriteService.countLikesForSong(widget.playlist[_currentSongIndex].id.toString());
      bool liked = await _favoriteService.checkIfLiked(widget.playlist[_currentSongIndex].id.toString());

      setState(() {
        _likeCount = likeCount;
        _isLiked = liked;
      });
    } catch (e) {
      print('Error fetching like count: $e');
    }
  }

  void _toggleLike() async {
    try {
      final songId = widget.playlist[_currentSongIndex].id.toString();
      if (songId.isEmpty) {
        throw Exception('Song ID cannot be null or empty');
      }

      if (_isLiked) {
        await _favoriteService.unlikeSong(songId);
        setState(() {
          _likeCount--;
          _isLiked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bạn đã bỏ thích bài hát này.')));
      } else {
        bool liked = await _favoriteService.checkIfLiked(songId);
        if (liked) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bài hát đã được thích rồi!')));
          return;
        }

        await _favoriteService.likeSong(songId);
        int likeCount = await _favoriteService.countLikesForSong(songId);
        setState(() {
          _likeCount = likeCount;
          _isLiked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bạn đã thích bài hát này.')));
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
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

  void _nextSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % widget.playlist.length;
      _playAudio();
      _fetchLikeCount();
    });
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + widget.playlist.length) % widget.playlist.length;
      _playAudio();
      _fetchLikeCount();
    });
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping; // Đảo ngược trạng thái phát lại
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
    final currentSong = widget.playlist[_currentSongIndex];

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
                    backgroundImage: NetworkImage(currentSong.image ?? 'https://example.com/default_image.jpg'),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text('Playing: ${currentSong.name}'),
            Text('Artist: ${currentSong.artist}'),
            Text('${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}'),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (value) {
                _seekTo(value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: _previousSong, child: Icon(Icons.skip_previous, size: 32)),
                SizedBox(width: 20),
                TextButton(onPressed: _isPlaying ? _pauseAudio : _playAudio, child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32)),
                SizedBox(width: 20),
                TextButton(onPressed: _nextSong, child: Icon(Icons.skip_next, size: 32)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.repeat, color: _isLooping ? Colors.orange : Colors.black), // Màu sắc tùy theo trạng thái
                  onPressed: _toggleLoop,
                ),
                SizedBox(width: 10),
                IconButton(icon: Icon(Icons.favorite, color: _isLiked ? Colors.orange : Colors.black), onPressed: _toggleLike),
                SizedBox(width: 10),
                Text('Likes: $_likeCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}