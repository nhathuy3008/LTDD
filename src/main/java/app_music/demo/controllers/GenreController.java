package app_music.demo.controllers;

import app_music.demo.Model.Genre;
import app_music.demo.Service.GenreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/genres")
public class GenreController {
    @Autowired
    private GenreService genreService;

    @PostMapping("/create")
    public Genre createGenre(@RequestBody Genre genre){
        return genreService.saveGenre(genre);
    }
    @GetMapping
    public List<Genre> getAllGenre (){
        return genreService.getAllGenre();
    }
    @GetMapping("/{id}")
    public Genre getGenreById(@PathVariable Long id){
        return genreService.getGenreById(id);
    }
    @DeleteMapping("/{id}")
    public void deleteById (@PathVariable Long id){
        genreService.deleteGenre(id);
    }
}
