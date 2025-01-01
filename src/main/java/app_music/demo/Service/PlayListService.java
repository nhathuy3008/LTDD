package app_music.demo.Service;

import app_music.demo.Model.Playlist;
import app_music.demo.Model.Song;
import app_music.demo.repository.PlaylistRepository;
import app_music.demo.repository.SongRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;

@Service
public class PlayListService {
    @Autowired
    private PlaylistRepository playlistRepository;

    @Autowired
    private SongRepository songRepository;

    public List<Playlist> getAllPlayList() {
        return playlistRepository.findAll();
    }

    public Playlist getPlayListById(Long id) {
        return playlistRepository.findById(id).orElse(null);
    }

    public Playlist savePlayList(Playlist playlist) {
        return playlistRepository.save(playlist);
    }

    public void deletePlayList(Long id) {
        playlistRepository.deleteById(id);
    }

    public void addSongsToPlaylist(Long playlistId, List<Long> songIds) {
        Playlist playlist = getPlayListById(playlistId);
        if (playlist == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Playlist không tồn tại");
        }

        List<Song> songsToAdd = new ArrayList<>();
        for (Long songId : songIds) {
            Song song = songRepository.findById(songId).orElse(null);
            if (song == null) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Bài hát không tồn tại với ID: " + songId);
            }

            // Kiểm tra xem nghệ sĩ của bài hát có giống với nghệ sĩ của playlist không
            if (!song.getArtist().equals(playlist.getArtist())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Đây là album của nghệ sĩ " + playlist.getArtist());
            }

            songsToAdd.add(song);
        }

        // Thêm bài hát vào playlist
        playlist.getSongs().addAll(songsToAdd);
        savePlayList(playlist); // Lưu lại playlist với các bài hát đã thêm
    }

    public List<Song> getSongsInPlaylist(Long playlistId) {
        Playlist playlist = getPlayListById(playlistId);
        return playlist != null ? playlist.getSongs() : null;
    }
}