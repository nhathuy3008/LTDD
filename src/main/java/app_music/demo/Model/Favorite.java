package app_music.demo.Model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Favorite {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "account_id")
    private Account account; // Người dùng

    @ManyToOne
    @JoinColumn(name = "song_id")
    private Song song; // Bài hát yêu thích
}
