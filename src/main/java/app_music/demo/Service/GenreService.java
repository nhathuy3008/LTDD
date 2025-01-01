package app_music.demo.Service;

import app_music.demo.Model.Genre;
import app_music.demo.repository.GenreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GenreService {
    @Autowired
    private GenreRepository genreRepository;

    public List<Genre> getAllGenre (){
        return genreRepository.findAll();
    }
    public Genre getGenreById (Long id){
        return genreRepository.findById(id).orElse(null);
    }
    public Genre saveGenre (Genre genre){
        return genreRepository.save(genre);
    }
    public void deleteGenre (Long id){
        genreRepository.deleteById(id);
    }
}
