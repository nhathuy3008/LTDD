package app_music.demo.controllers;

import app_music.demo.Model.Playlist;
import app_music.demo.Service.PlayListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/playlists")
public class PlayListController {
    @Autowired
    private PlayListService playListService;

    // Thêm playlist
    @PostMapping("/create")
    public Playlist createPlayList(@RequestBody Playlist playlist) {
        return playListService.savePlayList(playlist);
    }

    // Lấy danh sách tất cả playlist
    @GetMapping
    public List<Playlist> getAllPlayList() {
        return playListService.getAllPlayList();
    }

    // Lấy thông tin playlist theo ID
    @GetMapping("/{id}")
    public Playlist getPlayListById(@PathVariable Long id) {
        return playListService.getPlayListById(id);
    }

    // Cập nhật playlist
    @PutMapping("/{id}")
    public Playlist updatePlayList(@PathVariable Long id, @RequestBody Playlist playlist) {
        playlist.setId(id);
        return playListService.savePlayList(playlist);
    }

    // Xóa playlist
    @DeleteMapping("/{id}")
    public void deletePlayList(@PathVariable Long id) {
        playListService.deletePlayList(id);
    }

    // Thêm bài hát vào playlist
    @PostMapping("/{id}/songs")
    public void addSongsToPlaylist(@PathVariable Long id, @RequestBody List<Long> songIds) {
        playListService.addSongsToPlaylist(id, songIds);
    }
}