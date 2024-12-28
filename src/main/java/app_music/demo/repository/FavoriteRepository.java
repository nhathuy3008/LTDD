package app_music.demo.repository;

import app_music.demo.Model.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface FavoriteRepository extends JpaRepository <Favorite, Long> {
    Optional<Favorite> findByAccountIdAndSongId(UUID accountId, Long songId);
}
