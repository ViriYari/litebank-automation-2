package tests;

import base.BaseTest;
import pages.TransferPage;

import java.time.Duration;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;


public class TransferTest extends BaseTest {

@Test
    void e2e_transfer_test() {
        TransferPage page = new TransferPage(driver);
        
        // 1. Abrir aplicación
        page.openApp();

        // 2. Ejecutar flujo
        page.createTransfer("98765", "100");
       
        // 1. "Cachamos" el primer estado: PENDIENTE
    String estadoInicial = page.getStatusMessage();
    Assertions.assertEquals("Estado: PENDIENTE", estadoInicial);

    // 2. Esperamos a que cambie al estado final: ERROR
    // Usamos una nueva espera que "mire" hasta que el texto sea el de error
    WebDriverWait waitCambio = new WebDriverWait(driver, Duration.ofSeconds(10));
    waitCambio.until(ExpectedConditions.textToBePresentInElementLocated(By.xpath("//*[@id=\"status-box\"]"), "ERROR_ENVIANDO_TRANSFERENCIA"));
    
    // 3. Verificamos el estado final
    String estadoFinal = page.getStatusMessage();
    Assertions.assertEquals("Estado: ERROR_ENVIANDO_TRANSFERENCIA", estadoFinal);

    }
    }




    