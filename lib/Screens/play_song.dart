import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Models/Song.dart';
import '../Models/Comment.dart';
import '../Services/favorite_service.dart';
import '../Services/comment_service.dart';

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
  final CommentService _commentService = CommentService();

  bool _isPlaying = false;
  bool _isLooping = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _likeCount = 0;
  bool _isLiked = false;
  List<Comment> _comments = [];
  bool _showCommentInput = false;
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();
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
    _fetchComments();
  }

  void _fetchComments() async {
    try {
      final songId = widget.playlist[_currentSongIndex].id.toString();
      List<Comment> comments = await _commentService.getCommentsBySongId(songId);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  void _fetchLikeCount() async {
    try {
      final songId = widget.playlist[_currentSongIndex].id.toString();
      int likeCount = await _favoriteService.countLikesForSong(songId);
      bool liked = await _favoriteService.checkIfLiked(songId);
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
      _fetchComments();
    });
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + widget.playlist.length) % widget.playlist.length;
      _playAudio();
      _fetchLikeCount();
      _fetchComments();
    });
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
  }

  void _toggleShowComments() {
    setState(() {
      _showComments = !_showComments;
      _showCommentInput = _showComments; // Hiển thị ô nhập bình luận khi danh sách bình luận được mở
    });
  }

  void _submitComment() async {
    if (_commentController.text.isNotEmpty) {
      try {
        final songId = widget.playlist[_currentSongIndex].id;
        await _commentService.addComment({
          'comment': _commentController.text,
          'account': {'id': widget.accountId},
          'song': {'id': songId},
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bình luận đã được gửi!')));
        _commentController.clear();
        _fetchComments(); // Cập nhật danh sách bình luận sau khi gửi
      } catch (e) {
        print('Error submitting comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi gửi bình luận: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng nhập bình luận trước khi gửi.')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[_currentSongIndex];
    return Scaffold(
      appBar: AppBar(title: Text(currentSong.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Điều chỉnh kích thước theo kích thước màn hình
          double avatarRadius = constraints.maxWidth < 600 ? 50 : 100;  // Thay đổi kích thước avatar
          double fontSize = constraints.maxWidth < 600 ? 14 : 20;       // Thay đổi kích thước chữ

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * 3.14159265359,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundImage: NetworkImage(currentSong.image ?? 'https://example.com/default_image.jpg'),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Playing: ${currentSong.name}', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
                  Text('Artist: ${currentSong.artist}', style: TextStyle(fontSize: fontSize - 4)),
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
                      IconButton(icon: Icon(Icons.skip_previous, size: 32), onPressed: _previousSong),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
                        onPressed: _isPlaying ? _pauseAudio : _playAudio,
                      ),
                      SizedBox(width: 20),
                      IconButton(icon: Icon(Icons.skip_next, size: 32), onPressed: _nextSong),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.repeat, color: _isLooping ? Colors.orange : Colors.black),
                        onPressed: _toggleLoop,
                      ),
                      SizedBox(width: 10),
                      IconButton(icon: Icon(Icons.favorite, color: _isLiked ? Colors.orange : Colors.black), onPressed: _toggleLike),
                      SizedBox(width: 10),
                      Text('Likes: $_likeCount'),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.comment),
                            onPressed: _toggleShowComments,
                          ),
                          Text('${_comments.length}'), // Hiển thị số lượng bình luận
                        ],
                      ),
                    ],
                  ),
                  // Hiển thị ô nhập bình luận ở trên danh sách bình luận nếu _showComments là true
                  if (_showComments)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(hintText: 'Nhập bình luận...'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: _submitComment,
                          ),
                        ],
                      ),
                    ),
                  // Hiển thị danh sách bình luận nếu _showComments là true
                  if (_showComments)
                    Container(
                      height: 300, // Giới hạn chiều cao
                      child: ListView.builder(
                        itemCount: _comments.length, // Hiển thị tất cả bình luận
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return ListTile(
                            title: Text(comment.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(comment.content),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}