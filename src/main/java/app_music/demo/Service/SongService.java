package app_music.demo.Service;

import app_music.demo.Model.Song;
import app_music.demo.repository.SongRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
public class SongService {
    @Autowired
    private SongRepository songRepository;

    public List<Song> getAllSongs () {
        return songRepository.findAll();
    }
    public Song getSongById(Long id){
        return songRepository.findById(id).orElse(null);
    }
    public Song saveSong(Song song) {
        return songRepository.save(song);
    }
    public void deleteSong(Long id) {
        songRepository.deleteById(id);
    }
}
