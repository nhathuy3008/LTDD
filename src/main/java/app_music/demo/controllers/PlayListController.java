package app_music.demo.controllers;

import app_music.demo.Model.Playlist;
import app_music.demo.Model.Song;
import app_music.demo.Service.PlayListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/playlists")
public class PlayListController {
    @Autowired
    private PlayListService playListService;

    //thêm
    @PostMapping("/create")
    public Playlist createPlayList (@RequestBody Playlist playlist){
        return playListService.savePlayList(playlist);
    }

    //lấy danh sách
    @GetMapping
    public List<Playlist> getAllPlayList(){
        return playListService.getAllPlayList();
    }

    //lấy thông tin
    @GetMapping("/{id}")
    public Playlist getPlayListById (@PathVariable Long id){
        return playListService.getPlayListById(id);
    }
    //cập nhật
    @PutMapping("/{id}")
    public Playlist updatePlayList(@PathVariable Long id, @RequestBody Playlist playlist) {
        playlist.setId(id);
        return playListService.savePlayList(playlist);
    }
    //xóa
    @DeleteMapping("/{id}")
    public void deletePlayList (@PathVariable Long id){
        playListService.deletePlayList(id);
    }
}
