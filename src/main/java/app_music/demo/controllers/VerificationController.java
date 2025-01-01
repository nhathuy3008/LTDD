package app_music.demo.controllers;



import app_music.demo.Service.AccountService;
import app_music.demo.Service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

@Controller
public class VerificationController {

    private final AccountService accountService;
    private final EmailService emailService;

    @Autowired
    public VerificationController(AccountService accountService, EmailService emailService) {
        this.accountService = accountService;
        this.emailService = emailService;
    }

    @GetMapping("/verify")
    public ModelAndView verifyAccount(@RequestParam("token") String token, @RequestParam("email") String email) {
        ModelAndView modelAndView = new ModelAndView();
        try {
            boolean isVerified = accountService.verifyAccountByTokenAndEmail(token, email);
            if (isVerified) {
                emailService.sendVerificationSuccessEmail(email);
                RedirectView redirectView = new RedirectView("http://localhost:5173/", true);
                modelAndView.setView(redirectView);
                modelAndView.addObject("message", "Account verified successfully.");
                return modelAndView; // Successful verification and redirect
            } else {
                modelAndView.addObject("message", "Invalid or expired verification token.");
            }
        } catch (Exception e) {
            modelAndView.addObject("message", "Error verifying account: " + e.getMessage());
        }
        modelAndView.setViewName("error"); // Handle errors gracefully
        return modelAndView;
    }

}
//    @PostMapping("/create")
//    public ResponseEntity<Song> createSong(
//            @RequestParam("file") MultipartFile file,
//            @RequestParam("name") String name,
//            @RequestParam("artist") String artist,
//            @RequestParam("genre_id") Long genreId) {
//
//        // Kiểm tra file
//        if (file.isEmpty() || !isValidAudioFile(file)) {
//            return ResponseEntity.badRequest().body(null);
//        }
//
//        // Lưu file vào server
//        String filePath = saveFile(file);
//
//        // Tạo đối tượng Song
//        Song song = new Song();
//        song.setName(name);
//        song.setArtist(artist);
//        song.setUrl(filePath);
//
//        // Tìm Genre từ genreId
//        Genre genre = genreService.getGenreById(genreId); // Sửa ở đây
//        if (genre == null) {
//            return ResponseEntity.badRequest().body(null); // Hoặc xử lý lỗi theo cách khác
//        }
//        song.setGenre(genre); // Thiết lập genre
//
//        // Lưu bài hát
//        Song savedSong = songService.saveSong(song);
//        return ResponseEntity.ok(savedSong);
//    }
//@GetMapping("/play/{id}")
//    public ResponseEntity<Resource> playSong(@PathVariable Long id) {
//        System.out.println("Nhận yêu cầu phát bài hát với ID: " + id);
//
//        Song song = songService.getSongById(id);
//        if (song == null) {
//            System.out.println("Bài hát không tồn tại với ID: " + id);
//            return ResponseEntity.notFound().build();
//        }
//
//        try {
//            // Chuyển đổi đường dẫn file thành URL hợp lệ
//            String filePath = song.getUrl(); // Giả sử song.getUrl() chứa đường dẫn file
//            Resource resource = new UrlResource(Paths.get(filePath).toUri()); // Tạo URL từ đường dẫn
//
//            System.out.println("URL bài hát: " + filePath);
//
//            if (resource.exists() && resource.isReadable()) {
//                return ResponseEntity.ok()
//                        .header(HttpHeaders.CONTENT_TYPE, "audio/mpeg")
//                        .body(resource);
//            } else {
//                System.out.println("File không tồn tại hoặc không thể đọc: " + filePath);
//                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
//            }
//        } catch (MalformedURLException e) {
//            System.out.println("URL không hợp lệ: " + e.getMessage());
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
//        } catch (Exception e) {
//            System.out.println("Lỗi không xác định: " + e.getMessage());
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//        }
//    }@GetMapping("/play/{id}")
////    public ResponseEntity<Resource> playSong(@PathVariable Long id) {
////        System.out.println("Nhận yêu cầu phát bài hát với ID: " + id);
////
////        Song song = songService.getSongById(id);
////        if (song == null) {
////            System.out.println("Bài hát không tồn tại với ID: " + id);
////            return ResponseEntity.notFound().build();
////        }
////
////        try {
////            // Chuyển đổi đường dẫn file thành URL hợp lệ
////            String filePath = song.getUrl(); // Giả sử song.getUrl() chứa đường dẫn file
////            Resource resource = new UrlResource(Paths.get(filePath).toUri()); // Tạo URL từ đường dẫn
////
////            System.out.println("URL bài hát: " + filePath);
////
////            if (resource.exists() && resource.isReadable()) {
////                return ResponseEntity.ok()
////                        .header(HttpHeaders.CONTENT_TYPE, "audio/mpeg")
////                        .body(resource);
////            } else {
////                System.out.println("File không tồn tại hoặc không thể đọc: " + filePath);
////                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
////            }
////        } catch (MalformedURLException e) {
////            System.out.println("URL không hợp lệ: " + e.getMessage());
////            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
////        } catch (Exception e) {
////            System.out.println("Lỗi không xác định: " + e.getMessage());
////            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
////        }
////    }
