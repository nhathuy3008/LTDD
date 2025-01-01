package app_music.demo.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Autowired
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendVerificationEmail(String to, String token, String email) throws MessagingException {
        String subject = "Xác nhận đăng ký tài khoản - App Music";
        String verificationLink = "http://localhost:8080/verify?token=" + token + "&email=" + email;

        String content = "<html>"
                + "<body style=\"font-family: Arial, sans-serif; line-height: 1.6; background-color: #111212; margin: 0; padding: 0;\">"
                + "<div style=\"max-width: 600px; margin: 20px auto; background: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);\">"
                + "<div style=\"padding: 20px; text-align: center; background-color: #f9f9f9;\">"
                + "<img src=\"https://res.cloudinary.com/dceicuawz/image/upload/v1735295229/q0yo6udkholfjvcwva2c.png\" alt=\"App Music Logo\" style=\"width: 150px; height: auto; margin-bottom: 10px;\">"
                + "<h1 style=\"color: #333333; font-size: 24px;\">Xác nhận đăng ký tài khoản</h1>"
                + "</div>"
                + "<div style=\"padding: 20px;\">"
                + "<p style=\"font-size: 16px; color: #333333;\">Cảm ơn bạn đã đăng ký tài khoản tại <b>App Music</b>.</p>"
                + "<p style=\"font-size: 16px; color: #333333;\">Vui lòng nhấn vào nút bên dưới để kích hoạt tài khoản của bạn:</p>"
                + "<div style=\"text-align: center; margin: 20px 0;\">"
                + "<a href=\"" + verificationLink + "\" style=\"display: inline-block; padding: 10px 20px; font-size: 16px; color: #ffffff; background-color: #007bff; text-decoration: none; border-radius: 5px;\">Kích hoạt tài khoản</a>"
                + "</div>"
                + "<p style=\"font-size: 14px; color: #666666;\">Nếu bạn không đăng ký tài khoản này, vui lòng bỏ qua email này.</p>"
                + "</div>"
                + "<div style=\"padding: 10px; text-align: center; background-color: #f1f1f1; font-size: 12px; color: #999999;\">"
                + "<p>App Music © 2024. Tất cả các quyền được bảo lưu.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";

        sendEmail(to, subject, content);
    }

    public void sendVerificationSuccessEmail(String to) throws MessagingException {
        String subject = "Kích hoạt tài khoản thành công - App Music";

        String content = "<html>"
                + "<body style=\"font-family: Arial, sans-serif; line-height: 1.6; background-color: #111212; margin: 0; padding: 0;\">"
                + "<div style=\"max-width: 600px; margin: 20px auto; background: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);\">"
                + "<div style=\"padding: 20px; text-align: center; background-color: #007bff;\">"
                + "<img src=\"https://res.cloudinary.com/dceicuawz/image/upload/v1735295229/q0yo6udkholfjvcwva2c.png\" alt=\"App Music Logo\" style=\"width: 150px; height: auto; margin-bottom: 10px;\">"
                + "<h1 style=\"color: #333333; font-size: 24px;\">Kích hoạt tài khoản thành công</h1>"
                + "</div>"
                + "<div style=\"padding: 20px;\">"
                + "<p style=\"font-size: 16px; color: #333333;\">Chúc mừng! Tài khoản của bạn đã được kích hoạt thành công tại <b>App Music</b>.</p>"
                + "<p style=\"font-size: 16px; color: #333333;\">Bây giờ bạn có thể đăng nhập và trải nghiệm các dịch vụ của chúng tôi.</p>"
                + "<div style=\"text-align: center; margin: 20px 0;\">"
                + "<a href=\"http://localhost:8080/login\" style=\"display: inline-block; padding: 10px 20px; font-size: 16px; color: #ffffff; background-color: #007bff; text-decoration: none; border-radius: 5px;\">Đăng nhập ngay</a>"
                + "</div>"
                + "</div>"
                + "<div style=\"padding: 10px; text-align: center; background-color: #f1f1f1; font-size: 12px; color: #999999;\">"
                + "<p>App Music © 2024. Tất cả các quyền được bảo lưu.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";

        sendEmail(to, subject, content);
    }

    private void sendEmail(String to, String subject, String content) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(content, true);
        mailSender.send(message);
    }
}
