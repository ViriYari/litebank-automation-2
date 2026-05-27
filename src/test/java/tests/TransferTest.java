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
       
  String mensajeEsperado = "Estado: ERROR_ENVIANDO_TRANSFERENCIA";
     
    // 3. Capturamos el texto para la validación final
    String statusFinal = page.getStatusMessage();
    
    // 4. Verificamos que sea igual
    Assertions.assertEquals(mensajeEsperado, statusFinal, "El mensaje final no coincide");
}
    }




    