package tests;

import base.BaseTest;
import static org.junit.jupiter.api.Assertions.assertEquals;
import pages.TransferPage;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.support.ui.WebDriverWait;

public class TransferTest extends BaseTest {

    @Test
    void e2e_transfer_test() {

        TransferPage page = new TransferPage(driver);
        
        // 1. Abrir aplicación
        page.openApp();

        // 2. Ejecutar flujo
        page.createTransfer("98765", "100");

 
    String textoReal = page.waitForProcessingMessage("Estado: PENDIENTE");
    assertEquals("Estado: PENDIENTE", textoReal);

    }
}

