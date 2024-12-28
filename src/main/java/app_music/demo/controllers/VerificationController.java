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
