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
       
      page.clickSendButtonAndVerifyPending();

    // Ahora, como ya sabemos que pasó por "PENDIENTE", 
    // podemos validar lo que quieras o simplemente continuar.
    System.out.println("El test detectó el estado PENDIENTE con éxito.");
    }
    }




    