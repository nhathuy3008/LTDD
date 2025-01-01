package app_music.demo.Service;

import app_music.demo.Model.Account;
import app_music.demo.Utils.PGPUtils;
import app_music.demo.repository.AccountRepository;
import jakarta.mail.MessagingException;
import org.apache.commons.codec.digest.DigestUtils;
import org.bouncycastle.openpgp.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.bouncycastle.openpgp.PGPPrivateKey;
@Service
public class AccountService {
    private final PGPPrivateKey pgpPrivateKey;
    private final EmailService emailService;
    private final PGPPublicKey pgpPublicKey;

    @Autowired
    public AccountService(AccountRepository accountRepository, EmailService emailService) {
        this.accountRepository = accountRepository;
        this.emailService = emailService;


        try {
            PGPKeyPair pgpKeyPair = PGPUtils.generateKeyPair();
            this.pgpPublicKey = pgpKeyPair.getPublicKey();
            this.pgpPrivateKey = pgpKeyPair.getPrivateKey();
        } catch (PGPException | NoSuchAlgorithmException | NoSuchProviderException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to initialize PGP keys");
        }

    }
    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private CloudinaryService cloudinaryService;


    private static final String IMAGE_UPLOAD_DIR = "src/main/resources/static/images/";

    public String saveImage(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File ảnh không được rỗng");
        }

        String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        File saveFile = new File(IMAGE_UPLOAD_DIR + fileName);
        file.transferTo(saveFile);

        return "/images/" + fileName;
    }

    //Tạo tai khoan moi
    public Account createAccount(Account account){
        //Kiểm tra nếu email da ton tai
        Optional<Account> checkEmail = accountRepository.findByEmail(account.getEmail());
        if(checkEmail.isPresent()){
            throw new IllegalArgumentException("Email đã được sử dụng.");
        }

        account.setPassword(DigestUtils.sha256Hex(account.getPassword()));
        // Tạo token xác thực và gửi email
        String verificationToken = UUID.randomUUID().toString();
        account.setVerificationToken(verificationToken);
        accountRepository.save(account);

        try {
            emailService.sendVerificationEmail(account.getEmail(), verificationToken, account.getEmail());
        } catch (MessagingException e) {
            e.printStackTrace();
            throw new RuntimeException("Không thể gửi email xác thực");
        }
        return accountRepository.save(account);
    }

    public boolean verifyAccountByTokenAndEmail(String token, String email) {
        Optional<Account> accountOptional = accountRepository.findByEmailAndVerificationToken(email, token);
        if (accountOptional.isPresent()) {
            Account account = accountOptional.get();
            account.setVerificationToken(null); // Clear the verification token
            account.setEnabled(true); // Enable the account
            accountRepository.save(account);
            return true;
        } else {
            return false;
        }
    }

    //danh sach tai khoan
    public List<Account> getAllAcounts(){
        return accountRepository.findAll();
    }

    //Lay thong tin tai khoan
    public Optional<Account> getAccountById(UUID id){
        return accountRepository.findById(id);
    }

    //Cap nhat thong tin tai khoan
    public Account updateAccount(UUID id, Account accountDetails) throws IOException {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Account not found"));

        account.setFullName(accountDetails.getFullName());

        if (accountDetails.getPassword() != null && !accountDetails.getPassword().isEmpty()) {
            account.setPassword(DigestUtils.sha256Hex(accountDetails.getPassword()));
        }

        //đẩy lên cloudianry để nó trả url
        if (accountDetails.getImage() != null && !accountDetails.getImage().isEmpty()) {
            try {
                String imageUrlString = accountDetails.getImage();
                File imageFile;

                if (imageUrlString.startsWith("data:")) { // Chuỗi Base64
                    String base64Image = extractBase64String(imageUrlString);
                    byte[] imageBytes = Base64.getDecoder().decode(base64Image);

                    imageFile = File.createTempFile("image", ".tmp");
                    try (FileOutputStream fos = new FileOutputStream(imageFile)) {
                        fos.write(imageBytes);
                    }
                } else { // URL HTTP/HTTPS
                    URL imageUrl = new URL(imageUrlString);
                    imageFile = File.createTempFile("image", ".tmp");
                    try (InputStream in = imageUrl.openStream()) {
                        Files.copy(in, imageFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }
                }

                String newImageUrl = cloudinaryService.uploadImage(imageFile);
                imageFile.delete();
                account.setImage(newImageUrl);

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return accountRepository.save(account);
    }
    //base64
    private String extractBase64String(String dataUrl){
        String base64Image = dataUrl.split(",")[1];
        return base64Image;
    }

    //xoa tai khoan
    public void deleteAccount(UUID id){
        accountRepository.deleteById(id);
    }

    // Đăng nhập tài khoản
    public Optional<Account> login(String email, String password) {
        // Tìm tài khoản bằng email
        Optional<Account> optionalAccount = accountRepository.findByEmail(email);

        if (optionalAccount.isPresent()) {
            Account account = optionalAccount.get();

            // Kiểm tra nếu tài khoản chưa được kích hoạt
            if (!account.isEnabled()) {
                throw new IllegalArgumentException("Tài khoản chưa được xác nhận. Vui lòng kiểm tra email của bạn.");
            }

            // Kiểm tra mật khẩu đã mã hóa
            if (account.getPassword().equals(DigestUtils.sha256Hex(password))) {
                return Optional.of(account);
            } else {
                throw new IllegalArgumentException("Email hoặc mật khẩu không đúng.");
            }
        }

        throw new IllegalArgumentException("Email hoặc mật khẩu không đúng.");
    }

    //Kiem tra mat khau
    public boolean validatePassword(UUID id, String oldPassword) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
        String hashedOldPassword = DigestUtils.sha256Hex(oldPassword);
        return account.getPassword().equals(hashedOldPassword);
    }
    public long getTotalUsers() {
        return accountRepository.count(); // Đếm tất cả tài khoản
    }

}

