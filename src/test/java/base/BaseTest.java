package base;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

import java.time.Duration;

public class BaseTest {

    protected WebDriver driver;

    @BeforeEach
    void setUp() {
        // Configuraciones para que Chrome funcione en la nube (GitHub Actions)
        WebDriverManager.chromedriver().setup();

        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless=new"); // Ejecuta sin abrir ventana
        options.addArguments("--no-sandbox");   // Evita problemas de seguridad en Linux
        options.addArguments("--disable-dev-shm-usage"); // Optimiza el uso de memoria

        driver = new ChromeDriver(options); // Pasamos las opciones aquí

        driver.manage().window().maximize();

        driver.manage().timeouts()
                .implicitlyWait(Duration.ofSeconds(5));
    }

    @AfterEach
    void tearDown() {

        if (driver != null) {
            driver.quit();
        }
    }
}