package app_music.demo.controllers;


import app_music.demo.Model.Account;
import app_music.demo.Service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.util.*;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    @Autowired
    private AccountService accountService;

    //api tao khoan moi
    @PostMapping("/create")
    public Map<String, Object> createAccount(@RequestBody Account account){

        Map<String,Object> response =  new HashMap<>();

        try{
            Account createdAccount = accountService.createAccount(account);
            response.put(("message"),"Tài khoản đã được tạo thành công");
            response.put(("status"),"thành công");
            response.put(("account"),createdAccount);
        }catch (IllegalArgumentException e){
            response.put(("message"),e.getMessage());
            response.put(("status"),"lỗi");

        }catch (Exception e){
            response.put(("message"),"Đã có lỗi khi tạo tài khoản");
            response.put(("status"),"lỗi");

        }
        return response;
    }

    //api danh sach tai khoan
    @GetMapping
    public List<Account> getALlAcounts(){
        return accountService.getAllAcounts();
    }

    //api lay thong tin tai khoan theo id
    @GetMapping("/{id}")
    public Optional<Account>getAccountById(@PathVariable UUID id){
        return accountService.getAccountById(id);
    }

    @PutMapping("/{id}")
    public Account updateAccount (@PathVariable UUID id,@RequestBody Account accountDetails) throws IOException {
        return  accountService.updateAccount(id,accountDetails);
    }
    @DeleteMapping("/{id}")
    public Map<String, String> deleteAccount(@PathVariable UUID id){
        accountService.deleteAccount(id);
        Map<String, String > res = new HashMap<>();
        res.put("message","Xóa tài khoản thành công");
        return res;
    }

    //API dang nhap
    @PostMapping("/login")
    public Map<String,Object>login(@RequestParam String email,@RequestParam String password){
        Map<String,Object> response = new HashMap<>();
        Optional<Account> account = accountService.login(email,password);
        if(account.isPresent()){
            response.put(("message"),"Đăng nhập thành công");
            response.put(("status"),"thành công");
            response.put(("id"),account.get().getId());

        }else{
            response.put(("message"),"Email hoặc mật khẩu không hợp lệ");
            response.put(("status"),"lỗi");
        }
        return response;
    }
    //kiem tra mat khau cu
    @PostMapping("/validate-password")
    public Map<String, Object> validatePassword (@RequestParam UUID id ,@RequestParam String oldPassword ){
        Map<String, Object> response = new HashMap<>();
        boolean isVaild = accountService.validatePassword(id ,oldPassword);
        if(isVaild){
            response.put(("message"),"Mật khẩu hợp lệ");
            response.put(("status"),"thành công");
        }else{
            response.put(("message"),"Mật khẩu cũ không hợp lệ");
            response.put(("status"),"lỗi");
        }
        return response;
    }
    @GetMapping("/total")
    public ResponseEntity<Long> getTotalUsers() {
        long totalUsers = accountService.getTotalUsers();
        return ResponseEntity.ok(totalUsers);
    }


}

