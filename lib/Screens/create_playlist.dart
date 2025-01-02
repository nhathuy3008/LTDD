import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Models/Playlist.dart';
import '../Services/playlist_service.dart';

class CreatePlaylistPage extends StatefulWidget {
  @override
  _CreatePlaylistPageState createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final _formKey = GlobalKey<FormState>();
  final PlaylistService _playlistService = PlaylistService();
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _artist = '';
  Uint8List? _imageBytes;
  bool isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageBytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          print('Selected image path: ${pickedFile.path}');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn hình ảnh.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn hình ảnh: $e')),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn hình ảnh.')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        Playlist newPlaylist = Playlist(
          id: 0,
          name: _name.isNotEmpty ? _name : 'Tên Playlist Mặc Định',
          artist: _artist.isNotEmpty ? _artist : 'Nghệ Sĩ Mặc Định',
          image: '',
          songIds: [],
        );

        // Gọi phương thức tạo playlist
        await _playlistService.createPlaylist(newPlaylist, _imageBytes!, 'playlist_image.jpg');

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playlist đã được tạo thành công!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _imageBytes = null;
          isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Playlist Mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên Playlist'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên playlist';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nghệ Sĩ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên nghệ sĩ';
                  }
                  return null;
                },
                onSaved: (value) => _artist = value!,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Hình Ảnh',
                      hintText: _imageBytes != null ? 'Hình ảnh đã chọn' : 'Chọn hình ảnh',
                    ),
                  ),
                ),
              ),
              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.memory(
                    _imageBytes!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                child: Text('Tạo Playlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}