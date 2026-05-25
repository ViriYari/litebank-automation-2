package pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public class TransferPage {

    private WebDriver driver;
    private WebDriverWait wait;

    public TransferPage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(15
            
        ));
    }

    // Localizadores
    private By targetInput = By.xpath("//*[@id=\"root\"]/div/div/input[1]");
    private By amountInput = By.xpath("//*[@id=\"root\"]/div/div/input[2]");
    private By sendButton = By.xpath("//*[@id=\"root\"]/div/div/button");

    private By processingMsg = By.xpath("//*[@id=\"status-box\"]");
   

    // Acciones
   public void openApp() {
    String baseUrl = System.getProperty("BASE_URL", "http://localhost:5173");
    driver.get(baseUrl);
}

    public void fillForm(String target, String amount) {
        driver.findElement(targetInput).sendKeys(target);
        driver.findElement(amountInput).sendKeys(amount);
    }

    public void clickSend() {
        driver.findElement(sendButton).click();
    }

    public void createTransfer(String target, String amount) {
        fillForm(target, amount);
        clickSend();
    }

    
     public String getProcessingMessageText() {
    // 1. Espera a que sea visible y al mismo tiempo lo guarda
    WebElement element = wait.until(ExpectedConditions.visibilityOfElementLocated(processingMsg));
    // 2. Devuelve el texto real del elemento
    return element.getText();
}

}

   
