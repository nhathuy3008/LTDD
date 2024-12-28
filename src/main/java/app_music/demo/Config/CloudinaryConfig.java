package app_music.demo.Config;

import app_music.demo.Service.CloudinaryService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CloudinaryConfig implements WebMvcConfigurer {

    @Value("${cloudianry.cloud_name}")
    private String cloudName;
    @Value("${cloudianry.api_key}")
    private String apiKey;
    @Value("${cloudianry.api_secret}")
    private String apiSecret;
    @Bean
    CloudinaryService cloudinaryService(){
        return new CloudinaryService(cloudName,apiKey,apiSecret);
    }
}

