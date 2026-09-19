package seleniumtests;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class LoginTest {

    public static void main(String[] args) {

        WebDriver driver = new ChromeDriver();

        try {
            driver.get("http://localhost:8080/ElderEarn/jsp/auth/login.jsp");

            driver.findElement(By.id("email"))
                    .sendKeys("sobin88912@gmail.com");

            driver.findElement(By.id("password"))
                    .sendKeys("123");

            driver.findElement(By.cssSelector("button[type='submit']"))
                    .click();

            Thread.sleep(2000);

            String currentUrl = driver.getCurrentUrl();

            System.out.println("Current URL: " + currentUrl);
            System.out.println();

            if (currentUrl.contains("teacher-dashboard.jsp")) {
                System.out.println("-------------------------");
                System.out.println("Login successful!");
                System.out.println("LOGIN TEST PASSED");
                System.out.println("-------------------------");
            } else {
                System.out.println("LOGIN TEST FAILED");
            }

        } catch (Exception e) {
            System.out.println("LOGIN TEST FAILED");
        }

        driver.quit();
    }
}