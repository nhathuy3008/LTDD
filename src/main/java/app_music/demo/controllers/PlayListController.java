package app_music.demo.controllers;

import app_music.demo.Model.Playlist;
import app_music.demo.Model.Song;
import app_music.demo.Service.PlayListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;

import java.util.Base64;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/playlists")
public class PlayListController {
    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private PlayListService playListService;

    // Thêm playlist
    @Value("${github.token}")
    private String githubToken;

    @PostMapping("/create")
    public ResponseEntity<?> createPlayList(
            @RequestParam("image") MultipartFile image,
            @RequestParam("name") String name,
            @RequestParam(value = "artist", required = false) String artist) {

        if (image.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Tệp hình ảnh không được để trống!"));
        }

        try {
            // Xử lý tệp hình ảnh
            String imageFileName = System.currentTimeMillis() + "_" + name.replaceAll("[^a-zA-Z0-9.\\-]", "_") + ".jpg";
            byte[] imageContent = image.getBytes();
            String encodedImageContent = Base64.getEncoder().encodeToString(imageContent);

            String repo = "nhathuy3008/luu_nhac"; // Tên repo của bạn
            String gitImageUrl = "https://api.github.com/repos/" + repo + "/contents/" + imageFileName;

            String imageJsonPayload = "{\"message\":\"Upload image file\",\"content\":\"" + encodedImageContent + "\"}";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "token " + githubToken);

            HttpEntity<String> imageRequest = new HttpEntity<>(imageJsonPayload, headers);
            ResponseEntity<String> gitImageResponse = restTemplate.exchange(gitImageUrl, HttpMethod.PUT, imageRequest, String.class);

            if (gitImageResponse.getStatusCode() != HttpStatus.CREATED) {
                return ResponseEntity.status(gitImageResponse.getStatusCode())
                        .body(Map.of("error", "Lỗi từ GitHub khi tải tệp hình ảnh: " + gitImageResponse.getBody()));
            }

            // Tạo URL tải xuống cho hình ảnh
            String imageDownloadUrl = "https://raw.githubusercontent.com/" + repo + "/main/" + imageFileName;

            // Tạo một đối tượng Playlist mới
            Playlist newPlaylist = new Playlist();
            newPlaylist.setName(name);
            newPlaylist.setImage(imageDownloadUrl);
            newPlaylist.setArtist(artist); // Lưu nghệ sĩ nếu có

            // Lưu playlist vào cơ sở dữ liệu
            playListService.savePlayList(newPlaylist);

            return ResponseEntity.ok(Map.of("message", "Playlist đã được tạo thành công!"));
        } catch (Exception e) {
            e.printStackTrace(); // In ra lỗi chi tiết
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Lỗi không xác định: " + e.getMessage()));
        }
    }

    // Lấy danh sách tất cả playlist
    @GetMapping
    public List<Playlist> getAllPlayList() {
        return playListService.getAllPlayList();
    }

    // Lấy thông tin playlist theo ID
    @GetMapping("/{id}")
    public Playlist getPlayListById(@PathVariable Long id) {
        return playListService.getPlayListById(id);
    }

    // Cập nhật playlist
    @PutMapping("/{id}")
    public Playlist updatePlayList(@PathVariable Long id, @RequestBody Playlist playlist) {
        playlist.setId(id);
        return playListService.savePlayList(playlist);
    }

    // Xóa playlist
    @DeleteMapping("/{id}")
    public void deletePlayList(@PathVariable Long id) {
        playListService.deletePlayList(id);
    }
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<String> handleResponseStatusException(ResponseStatusException ex) {
        // Sử dụng ex.getStatusCode() để lấy mã trạng thái
        return ResponseEntity.status(ex.getStatusCode()).body(ex.getReason());
    }
    // Thêm bài hát vào playlist
    @PostMapping("/{id}/songs")
    public void addSongsToPlaylist(@PathVariable Long id, @RequestBody List<Long> songIds) {
        playListService.addSongsToPlaylist(id, songIds);
    }
    @GetMapping("/{id}/songs")
    public List<Song> getSongsInPlaylist(@PathVariable Long id) {
        return playListService.getSongsInPlaylist(id);
    }
}