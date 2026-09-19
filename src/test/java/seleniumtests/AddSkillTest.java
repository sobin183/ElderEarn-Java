package seleniumtests;

import java.time.Duration;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

public class AddSkillTest {

    public static void main(String[] args) throws InterruptedException {

        WebDriver driver = new ChromeDriver();
        driver.manage().window().maximize();

        try {
            driver.get("http://localhost:8080/ElderEarn/jsp/auth/login.jsp");

            driver.findElement(By.id("email")).sendKeys("sobin88912@gmail.com");
            driver.findElement(By.id("password")).sendKeys("123");
            driver.findElement(By.cssSelector("button[type='submit']")).click();

            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(8));
            wait.until(ExpectedConditions.urlContains("teacher-dashboard.jsp"));

            driver.get("http://localhost:8080/ElderEarn/jsp/teacher/add-skill.jsp");

            wait.until(ExpectedConditions.presenceOfElementLocated(By.id("skill_title")));

            driver.findElement(By.id("skill_title"))
                    .sendKeys("Organic Kitchen Gardening");

            new Select(driver.findElement(By.id("category")))
                    .selectByValue("Agriculture");

            driver.findElement(By.id("price")).sendKeys("250");
            driver.findElement(By.id("description"))
                    .sendKeys("Basics of vermicomposting, soil nutrition, and kitchen gardening.");

            WebElement submitBtn = driver.findElement(By.cssSelector("button[type='submit']"));
            ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", submitBtn);
            Thread.sleep(500);
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", submitBtn);

            wait.until(ExpectedConditions.urlContains("view-my-skills.jsp"));

            System.out.println("SKILL ADDED SUCCESSFULLY");
            System.out.println("Enter Skill Title: Organic Kitchen Gardening");
            System.out.println("Enter Category: Agriculture");
            System.out.println("Enter Price: 250");
            System.out.println("Skill Added Successfully");
            System.out.println("ADD SKILL TEST PASSED");

        } catch (Exception e) {
            System.out.println("ADD SKILL TEST FAILED: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }
}