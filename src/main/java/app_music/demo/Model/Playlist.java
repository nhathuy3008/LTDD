package app_music.demo.Model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Playlist {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Tên danh sách phát là bắt buộc!")
    private String name;

    private String image; // Đường dẫn hình ảnh của playlist

    @NotBlank(message = "Nghệ sĩ là bắt buộc!") // Bắt buộc nhập nghệ sĩ
    private String artist; // Nghệ sĩ của playlist

    @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "playlist_songs",
            joinColumns = @JoinColumn(name = "playlist_id"),
            inverseJoinColumns = @JoinColumn(name = "song_id")
    )
    private List<Song> songs = new ArrayList<>(); // Danh sách bài hát trong playlist
}