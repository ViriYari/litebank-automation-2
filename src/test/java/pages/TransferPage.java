package pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions; // Importante
import org.openqa.selenium.support.ui.WebDriverWait;
import java.time.Duration;

public class TransferPage {

    private WebDriver driver;
    private WebDriverWait wait;

    public TransferPage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(60));
    }

    // Localizadores (Sin cambios)
    private By targetInput = By.xpath("//*[@id=\"root\"]/div/div/input[1]");
    private By amountInput = By.xpath("//*[@id=\"root\"]/div/div/input[2]");
    private By sendButton = By.xpath("//*[@id=\"root\"]/div/div/button");
    private By processingMsg = By.id("status-box");

    // Acciones con Polling
    public void openApp() {
        driver.get("http://localhost:5173");
    }

    public void fillForm(String target, String amount) {
        // Espera a que el input sea visible antes de escribir
        wait.until(ExpectedConditions.visibilityOfElementLocated(targetInput)).sendKeys(target);
        driver.findElement(amountInput).sendKeys(amount);
    }

    public void clickSend() {
        // Espera a que el botón sea clickeable
        wait.until(ExpectedConditions.elementToBeClickable(sendButton)).click();
    }

    

    public void createTransfer(String target, String amount) {
        fillForm(target, amount);
        clickSend();
 }
    public String getStatusMessage() {
    // Esto espera a que el elemento sea visible y devuelve su texto actual
    WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(100));

    wait.until(
        ExpectedConditions.textToBe(processingMsg, "Estado: APROBADO")
    );

    WebElement element = driver.findElement(processingMsg);

    //System.out.println("EL TEXTO REAL EN EL STATUS-BOX ES: " + element.getText());
    return element.getText();
}
/*public String getStatusMessage() {

    long startTime = System.currentTimeMillis();

    WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(100));

    wait.until(
        ExpectedConditions.textToBe(processingMsg, "Estado: APROBADO")
    );

    WebElement element = driver.findElement(processingMsg);

    long endTime = System.currentTimeMillis();

    long totalTime = endTime - startTime;

    System.out.println("EL TEXTO REAL EN EL STATUS-BOX ES: " + element.getText());
    System.out.println("TIEMPO HASTA 'Estado: APROBADO': " + totalTime + " ms");
    System.out.println("TIEMPO EN SEGUNDOS: " + (totalTime / 1000.0));

    return element.getText();
}*/
}