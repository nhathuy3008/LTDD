package app_music.demo.Service;

import app_music.demo.Model.Favorite;
import app_music.demo.Model.Song;
import app_music.demo.repository.FavoriteRepository;
import app_music.demo.repository.SongRepository; // Import repository cho Song
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class FavoriteService {
    @Autowired
    private FavoriteRepository favoriteRepository;

    @Autowired
    private SongRepository songRepository; // Thêm SongRepository

    public Favorite saveFavorite(Favorite favorite) {
        Optional<Favorite> existingFavorite = favoriteRepository.findByAccountIdAndSongId(
                favorite.getAccount().getId(), favorite.getSong().getId());

        if (!existingFavorite.isPresent()) {
            Favorite savedFavorite = favoriteRepository.save(favorite);

            // Lấy bài hát từ cơ sở dữ liệu
            Song song = songRepository.findById(favorite.getSong().getId())
                    .orElseThrow(() -> new RuntimeException("Bài hát không tồn tại!"));

            // Cập nhật số lượng likes
            song.setLikeCount(song.getLikeCount() + 1);
            songRepository.save(song); // Lưu bài hát với số lượng likes đã cập nhật

            return savedFavorite;
        } else {
            throw new RuntimeException("Bài hát đã được thích rồi!");
        }
    }
}