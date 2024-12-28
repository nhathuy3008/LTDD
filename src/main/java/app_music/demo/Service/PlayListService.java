package app_music.demo.Service;

import app_music.demo.Model.Playlist;
import app_music.demo.repository.PlaylistRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PlayListService {
    @Autowired
    private PlaylistRepository playlistRepository;

    public List<Playlist> getAllPlayList(){
        return playlistRepository.findAll();
    }

    public Playlist getPlayListById (Long id){
        return playlistRepository.findById(id).orElse(null);
    }

    public Playlist savePlayList (Playlist playlist){
        return playlistRepository.save(playlist);
    }


    public void deletePlayList (Long id){
        playlistRepository.deleteById(id);
    }
}

