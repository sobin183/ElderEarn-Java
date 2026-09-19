package seleniumtests;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;

public class BrowseSkillsTest {

    public static void main(String[] args) throws InterruptedException {

        WebDriver driver = new ChromeDriver();

        try {
            driver.get("http://localhost:8080/ElderEarn/jsp/auth/login.jsp");

            driver.findElement(By.id("email")).sendKeys("chu@gmail.com");
            driver.findElement(By.id("password")).sendKeys("123");
            driver.findElement(By.cssSelector("button[type='submit']")).click();

            Thread.sleep(1500);

            driver.get("http://localhost:8080/ElderEarn/jsp/student/browse-skills.jsp");

            Thread.sleep(1500);

            List<WebElement> skillCards = driver.findElements(By.className("skill-card"));

            System.out.println("STUDENT MARKETPLACE LOADED");
            System.out.println("Current URL: " + driver.getCurrentUrl());
            System.out.println("Total Skills Available: " + skillCards.size());

            if (skillCards.size() > 0) {
                System.out.println("-------------------------");
                System.out.println("Skills Catalog Displayed Successfully!");
                System.out.println("BROWSE SKILLS TEST PASSED");
                System.out.println("-------------------------");
            } else {
                System.out.println("BROWSE SKILLS TEST FAILED");
            }

        } catch (Exception e) {
            System.out.println("BROWSE SKILLS TEST FAILED");
        }

        driver.quit();
    }
}