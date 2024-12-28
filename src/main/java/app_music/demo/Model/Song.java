package app_music.demo.Model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Entity
@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Song {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank (message = "Tên bài hát là bắt buộc !!!")
    private String name;

    @NotBlank(message = "Tên nghệ sĩ là bắt buộc!")
    private String artist;

    @NotBlank(message = "URL bài hát là bắt buộc!")
    private String url; // Đường dẫn file nhạc
    private String image;
    @ManyToOne
    @JoinColumn(name = "genre_id", nullable = false)
    private Genre genre;
    private int likeCount = 0;
}
