package app_music.demo.controllers;
import app_music.demo.Model.Genre;
import app_music.demo.Model.Song;
import app_music.demo.Service.GenreService;
import app_music.demo.Service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;


import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/songs")
public class SongController {
    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private SongService songService;
    @Autowired
    private GenreService genreService;

    @GetMapping
    public List<Song> getAllSongs() {
        return songService.getAllSongs();
    }

    @GetMapping("/{id}")
    public Song getSongById(@PathVariable Long id) {
        return songService.getSongById(id);
    }

    @Value("${github.token}")
    private String githubToken;

    @PostMapping("/create")
    public ResponseEntity<?> createSong(
            @RequestParam("file") MultipartFile file,
            @RequestParam("image") MultipartFile image, // Thêm tham số hình ảnh
            @RequestParam("name") String name,
            @RequestParam("artist") String artist,
            @RequestParam("genre_id") Long genreId) {

        if (file.isEmpty() || image.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Tệp âm thanh và hình ảnh không được để trống!"));
        }

        try {
            // Xử lý tệp âm thanh
            String audioFileName = System.currentTimeMillis() + "_" + name.replaceAll("[^a-zA-Z0-9.\\-]", "_") + ".mp3";
            byte[] audioContent = file.getBytes();
            String encodedAudioContent = Base64.getEncoder().encodeToString(audioContent);

            String repo = "nhathuy3008/luu_nhac";
            String gitAudioUrl = "https://api.github.com/repos/" + repo + "/contents/" + audioFileName;

            String audioJsonPayload = "{\"message\":\"Upload audio file\",\"content\":\"" + encodedAudioContent + "\"}";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "token " + githubToken);

            HttpEntity<String> audioRequest = new HttpEntity<>(audioJsonPayload, headers);
            ResponseEntity<String> gitAudioResponse = restTemplate.exchange(gitAudioUrl, HttpMethod.PUT, audioRequest, String.class);

            if (gitAudioResponse.getStatusCode() != HttpStatus.CREATED) {
                return ResponseEntity.status(gitAudioResponse.getStatusCode())
                        .body(Map.of("error", "Lỗi từ GitHub khi tải tệp âm thanh: " + gitAudioResponse.getBody()));
            }

            // Tạo URL tải xuống cho tệp âm thanh
            String audioDownloadUrl = "https://raw.githubusercontent.com/" + repo + "/main/" + audioFileName;

            // Xử lý tệp hình ảnh
            String imageFileName = System.currentTimeMillis() + "_" + name.replaceAll("[^a-zA-Z0-9.\\-]", "_") + ".jpg";
            byte[] imageContent = image.getBytes();
            String encodedImageContent = Base64.getEncoder().encodeToString(imageContent);

            String gitImageUrl = "https://api.github.com/repos/" + repo + "/contents/" + imageFileName;

            String imageJsonPayload = "{\"message\":\"Upload image file\",\"content\":\"" + encodedImageContent + "\"}";

            HttpEntity<String> imageRequest = new HttpEntity<>(imageJsonPayload, headers);
            ResponseEntity<String> gitImageResponse = restTemplate.exchange(gitImageUrl, HttpMethod.PUT, imageRequest, String.class);

            if (gitImageResponse.getStatusCode() != HttpStatus.CREATED) {
                return ResponseEntity.status(gitImageResponse.getStatusCode())
                        .body(Map.of("error", "Lỗi từ GitHub khi tải tệp hình ảnh: " + gitImageResponse.getBody()));
            }

            // Tạo URL tải xuống cho hình ảnh
            String imageDownloadUrl = "https://raw.githubusercontent.com/" + repo + "/main/" + imageFileName;

            // Tìm thể loại từ ID
            Genre genre = genreService.getGenreById(genreId);
            if (genre == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Thể loại không tồn tại!"));
            }

            // Tạo một đối tượng Song mới
            Song newSong = new Song();
            newSong.setFileName(audioFileName);
            newSong.setName(name);
            newSong.setArtist(artist);
            newSong.setUrl(audioDownloadUrl); // Lưu URL có thể tải xuống âm thanh
            newSong.setImage(imageDownloadUrl); // Lưu URL có thể tải xuống hình ảnh
            newSong.setGenre(genre);

            // Lưu bài hát vào cơ sở dữ liệu
            songService.saveSong(newSong);

            return ResponseEntity.ok(Map.of("message", "Tệp đã được tải lên thành công và lưu vào danh sách nhạc."));
        } catch (Exception e) {
            e.printStackTrace(); // In ra lỗi chi tiết
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Lỗi không xác định: " + e.getMessage()));
        }
    }
    // Phương thức kiểm tra định dạng file
    private boolean isValidAudioFile(MultipartFile file) {
        String contentType = file.getContentType();
        return contentType != null && contentType.startsWith("audio/");
    }

    @PutMapping("/{id}")
    public Song updateSong(@PathVariable Long id, @RequestBody Song song) {
        song.setId(id);
        return songService.saveSong(song);
    }

    @DeleteMapping("/{id}")
    public void deleteById(@PathVariable Long id) {
        songService.deleteSong(id);
    }
    //tim kiem song bang key work
    @GetMapping("/find/{name}")
    public List<Song> findSongsByName(@PathVariable String name) {
        return songService.findSongsByName(name);
    }
    @GetMapping("/play/{id}")
    public ResponseEntity<Resource> playSong(@PathVariable Long id) {
        Song song = songService.getSongById(id);
        if (song == null) {
            return ResponseEntity.notFound().build(); // Không tìm thấy bài hát
        }

        try {
            String filePath = song.getUrl(); // Lấy URL từ cơ sở dữ liệu

            // In ra thông tin file đang phát để kiểm tra
            System.out.println("Đang phát file: " + filePath);

            Resource resource = new UrlResource(filePath); // Tạo UrlResource từ URL

            if (resource.exists() && resource.isReadable()) {
                // Trả về tệp âm thanh và hiển thị thêm thông tin trong response
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_TYPE, "audio/mpeg")
                        .body(resource); // Trả về tệp âm thanh
            } else {
                System.out.println("Tệp không tồn tại hoặc không thể đọc: " + filePath);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build(); // Tệp không tồn tại hoặc không thể đọc
            }
        } catch (MalformedURLException e) {
            System.out.println("URL không hợp lệ: " + song.getUrl());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build(); // URL không hợp lệ
        } catch (Exception e) {
            System.out.println("Lỗi khi xử lý yêu cầu phát nhạc: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // Lỗi khác
        }
    }
}

