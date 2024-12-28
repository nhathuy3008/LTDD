package app_music.demo.controllers;

import app_music.demo.Model.Favorite;
import app_music.demo.Service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {
    @Autowired
    private FavoriteService favoriteService;

    // Thích bài hát
    @PostMapping("/like")
    public ResponseEntity<Favorite> likeSong(@RequestBody Favorite favorite) {
        Favorite savedFavorite = favoriteService.saveFavorite(favorite);
        return ResponseEntity.ok(savedFavorite);
    }
}

