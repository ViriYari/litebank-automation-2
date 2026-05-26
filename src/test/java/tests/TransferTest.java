package tests;

import base.BaseTest;
import pages.TransferPage;
import org.junit.jupiter.api.Test;


public class TransferTest extends BaseTest {

@Test
    void e2e_transfer_test() {
        TransferPage page = new TransferPage(driver);
        
        // 1. Abrir aplicación
        page.openApp();

        // 2. Ejecutar flujo
        page.createTransfer("98765", "100");

  
    }
    }




    