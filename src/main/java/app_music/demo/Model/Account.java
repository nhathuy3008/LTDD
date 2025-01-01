package app_music.demo.Model;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.UUID;

@Entity
@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Account {
    @Id
    private UUID id; // UUID sẽ được tự động sinh

    @NotBlank(message = "Họ và tên bắt buộc điền")
    private String fullName;

    @NotBlank(message = "Email bắt buộc điền")
    private String email;

    @NotBlank(message = "Mật khẩu bắt buộc điền")
    private String password;

    private String image;

    private boolean enabled = false;

    private String verificationToken;

    @PrePersist
    public void generateId() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }
}


