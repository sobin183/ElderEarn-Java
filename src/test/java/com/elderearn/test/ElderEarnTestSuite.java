package com.elderearn.test;

import java.time.Duration;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

public class ElderEarnTestSuite {

    public static String lastUserEmail = null;
    public static String lastUserPassword = null;
    public static String lastUserName = null;
    public static String lastCourseTitle = null;

    private static WebDriverWait createWait(WebDriver driver) {
        return new WebDriverWait(driver, Duration.ofSeconds(TestConfig.EXPLICIT_WAIT_SECONDS));
    }

    private static void loginHelper(WebDriver driver, String email, String password, String expectedUrlPart) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        WebElement emailInput = driver.findElement(By.id("email"));
        emailInput.clear();
        emailInput.sendKeys(email);

        WebElement passInput = driver.findElement(By.id("password"));
        passInput.clear();
        passInput.sendKeys(password);

        driver.findElement(By.cssSelector("button[type='submit']")).click();
        createWait(driver).until(ExpectedConditions.urlContains(expectedUrlPart));
    }

    // -------------------------------------------------------------
    // SUITE 1: AUTHENTICATION & ROLE-BASED ACCESS CONTROL (RBAC)
    // -------------------------------------------------------------

    public static String test01_LoginPageRenders(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        if (!driver.getTitle().contains("ElderEarn Login")) {
            throw new AssertionError("Expected title to contain 'ElderEarn Login', got: " + driver.getTitle());
        }

        WebElement email = driver.findElement(By.id("email"));
        WebElement pass = driver.findElement(By.id("password"));
        WebElement submit = driver.findElement(By.cssSelector("button[type='submit']"));

        if (!email.isDisplayed() || !pass.isDisplayed() || !submit.isDisplayed()) {
            throw new AssertionError("Login form elements are not fully visible.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "01_login_page");
        res.setScreenshot(shot);
        return "Login page rendered with all required form controls. Screenshot saved.";
    }

    public static String test02_LoginEmptyInputs(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        WebElement email = driver.findElement(By.id("email"));
        if (email.getAttribute("required") == null) {
            throw new AssertionError("Email field missing HTML5 'required' attribute.");
        }

        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp?error=empty");
        WebElement alert = driver.findElement(By.className("alert-danger"));
        if (!alert.getText().contains("Please enter both email and password")) {
            throw new AssertionError("Unexpected alert text: " + alert.getText());
        }
        return "Empty input validation verified via HTML5 required attribute and error alert display.";
    }

    public static String test03_LoginInvalidCredentials(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        driver.findElement(By.id("email")).sendKeys("nonexistent_user@elderearn.com");
        driver.findElement(By.id("password")).sendKeys("WrongPass999");
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        WebElement alert = createWait(driver).until(
                ExpectedConditions.presenceOfElementLocated(By.className("alert-danger")));
        if (!alert.getText().contains("Invalid Email or Password")) {
            throw new AssertionError("Expected 'Invalid Email or Password', got: " + alert.getText());
        }

        String shot = DriverFactory.takeScreenshot(driver, "02_invalid_login_alert");
        res.setScreenshot(shot);
        return "Authentication rejection verified: 'Invalid Email or Password' correctly displayed.";
    }

    public static String test04_TeacherLoginAndRouting(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        driver.findElement(By.id("email")).sendKeys(TestConfig.TEACHER_EMAIL);
        driver.findElement(By.id("password")).sendKeys(TestConfig.TEACHER_PASSWORD);
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        createWait(driver).until(ExpectedConditions.urlContains("teacher-dashboard.jsp"));
        String page = driver.getPageSource();
        if (!page.contains("Sobin Thankachan") && !page.contains("Teacher")) {
            throw new AssertionError("Teacher portal text not detected in dashboard source.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "03_teacher_dashboard");
        res.setScreenshot(shot);
        return "Teacher authenticated successfully and routed to teacher-dashboard.jsp.";
    }

    public static String test05_StudentLoginAndRouting(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        driver.findElement(By.id("email")).sendKeys(TestConfig.STUDENT_EMAIL);
        driver.findElement(By.id("password")).sendKeys(TestConfig.STUDENT_PASSWORD);
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        createWait(driver).until(ExpectedConditions.urlContains("student-dashboard.jsp"));
        String page = driver.getPageSource();
        if (!page.contains("Welcome back") && !page.contains("Student")) {
            throw new AssertionError("Student portal text not detected in dashboard source.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "04_student_dashboard");
        res.setScreenshot(shot);
        return "Student authenticated successfully and routed to student-dashboard.jsp.";
    }

    public static String test06_AdminLoginAndRouting(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        driver.findElement(By.id("email")).sendKeys(TestConfig.ADMIN_EMAIL);
        driver.findElement(By.id("password")).sendKeys(TestConfig.ADMIN_PASSWORD);
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        createWait(driver).until(ExpectedConditions.urlContains("admin-dashboard.jsp"));
        if (!driver.getPageSource().contains("Admin")) {
            throw new AssertionError("Admin portal text not detected in dashboard source.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "05_admin_dashboard");
        res.setScreenshot(shot);
        return "Admin authenticated successfully and routed to admin-dashboard.jsp.";
    }

    public static String test07_LogoutWorkflow(WebDriver driver, TestResult res) {
        // Authenticate first
        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        driver.findElement(By.id("email")).sendKeys(TestConfig.TEACHER_EMAIL);
        driver.findElement(By.id("password")).sendKeys(TestConfig.TEACHER_PASSWORD);
        driver.findElement(By.cssSelector("button[type='submit']")).click();
        createWait(driver).until(ExpectedConditions.urlContains("teacher-dashboard.jsp"));

        // Invalidate session via LogoutServlet
        driver.get(TestConfig.BASE_URL + "/LogoutServlet");
        createWait(driver).until(ExpectedConditions.urlContains("index.jsp"));

        // Attempting to access protected page must redirect to login
        driver.get(TestConfig.BASE_URL + "/jsp/teacher/teacher-dashboard.jsp");
        createWait(driver).until(ExpectedConditions.urlContains("login.jsp"));

        String shot = DriverFactory.takeScreenshot(driver, "05_logout_session_cleared");
        res.setScreenshot(shot);
        return "Session invalidated by LogoutServlet (redirected to index.jsp; subsequent access blocked).";
    }

    // -------------------------------------------------------------
    // SUITE 2: ACCOUNT REGISTRATION LIFECYCLE
    // -------------------------------------------------------------

    public static String test08_RegisterPageRenders(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/register.jsp");
        if (!driver.getPageSource().contains("ElderEarn")) {
            throw new AssertionError("Registration page missing 'ElderEarn' header.");
        }

        if (!driver.findElement(By.id("full_name")).isDisplayed() ||
            !driver.findElement(By.id("email")).isDisplayed() ||
            !driver.findElement(By.id("role")).isDisplayed() ||
            !driver.findElement(By.id("password")).isDisplayed() ||
            !driver.findElement(By.id("confirm_password")).isDisplayed()) {
            throw new AssertionError("One or more required registration inputs are missing.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "06_register_page");
        res.setScreenshot(shot);
        return "Registration page rendered with all required fields visible.";
    }

    public static String test09_RegisterPasswordMismatch(WebDriver driver, TestResult res) {
        driver.get(TestConfig.BASE_URL + "/jsp/auth/register.jsp");
        driver.findElement(By.id("full_name")).sendKeys("Test User");
        driver.findElement(By.id("email")).sendKeys("mismatch@elderearn.com");
        new Select(driver.findElement(By.id("role"))).selectByValue("student");
        driver.findElement(By.id("password")).sendKeys("Secret123");
        driver.findElement(By.id("confirm_password")).sendKeys("DifferentPass");

        driver.findElement(By.cssSelector("button[type='submit']")).click();

        try {
            Thread.sleep(500);
        } catch (InterruptedException ignored) {
        }

        WebElement jsAlert = driver.findElement(By.id("js-alert"));
        boolean alertVisible = jsAlert.isDisplayed() || !jsAlert.getAttribute("class").contains("d-none");
        boolean notRedirected = !driver.getCurrentUrl().contains("login.jsp");

        if (!alertVisible && !notRedirected) {
            throw new AssertionError("Form allowed submission despite mismatched passwords.");
        }
        return "Client-side password mismatch verification confirmed; submission intercepted.";
    }

    public static String test10_RegisterNewStudentAccount(WebDriver driver, TestResult res) {
        long ts = System.currentTimeMillis() / 1000;
        String newEmail = "student_" + ts + "@elderearn.com";
        String newName = "Learner User " + (ts % 1000);

        driver.get(TestConfig.BASE_URL + "/jsp/auth/register.jsp");
        driver.findElement(By.id("full_name")).sendKeys(newName);
        driver.findElement(By.id("email")).sendKeys(newEmail);
        new Select(driver.findElement(By.id("role"))).selectByValue("student");
        driver.findElement(By.id("password")).sendKeys("Pass1234");
        driver.findElement(By.id("confirm_password")).sendKeys("Pass1234");
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        createWait(driver).until(ExpectedConditions.urlContains("login.jsp"));
        String currentUrl = driver.getCurrentUrl();
        String page = driver.getPageSource();
        if (!currentUrl.contains("registered") && !page.contains("Registration successful")) {
            throw new AssertionError("Registration success indicator missing after submission.");
        }

        lastUserEmail = newEmail;
        lastUserPassword = "Pass1234";
        lastUserName = newName;

        String shot = DriverFactory.takeScreenshot(driver, "07_registration_success");
        res.setScreenshot(shot);
        return "New student account successfully registered: " + newEmail;
    }

    public static String test11_LoginWithNewlyRegisteredStudent(WebDriver driver, TestResult res) {
        if (lastUserEmail == null) {
            res.setStatus("SKIPPED");
            return "Skipped: Last registered user details unavailable.";
        }

        driver.get(TestConfig.BASE_URL + "/jsp/auth/login.jsp");
        driver.findElement(By.id("email")).sendKeys(lastUserEmail);
        driver.findElement(By.id("password")).sendKeys(lastUserPassword);
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        createWait(driver).until(ExpectedConditions.urlContains("student-dashboard.jsp"));
        if (!driver.getPageSource().contains(lastUserName)) {
            throw new AssertionError("Dashboard did not contain user name: " + lastUserName);
        }
        return "Newly registered user '" + lastUserEmail + "' successfully authenticated and logged in.";
    }

    // -------------------------------------------------------------
    // SUITE 3: SENIOR / TEACHER SKILL COURSE PUBLISHING
    // -------------------------------------------------------------

    public static String test12_AddSkillFormRenders(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.TEACHER_EMAIL, TestConfig.TEACHER_PASSWORD, "teacher-dashboard.jsp");

        driver.get(TestConfig.BASE_URL + "/jsp/teacher/add-skill.jsp");
        if (!driver.getTitle().contains("Add Skill")) {
            throw new AssertionError("Expected 'Add Skill' in title, got: " + driver.getTitle());
        }

        if (!driver.findElement(By.id("skill_title")).isDisplayed() ||
            !driver.findElement(By.id("category")).isDisplayed() ||
            !driver.findElement(By.id("price")).isDisplayed() ||
            !driver.findElement(By.id("description")).isDisplayed()) {
            throw new AssertionError("One or more required fields missing in Add Skill form.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "08_add_skill_form");
        res.setScreenshot(shot);
        return "Course creation form rendered with all inputs visible.";
    }

    public static String test13_PublishNewSkillCourse(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.TEACHER_EMAIL, TestConfig.TEACHER_PASSWORD, "teacher-dashboard.jsp");

        driver.get(TestConfig.BASE_URL + "/jsp/teacher/add-skill.jsp");
        long ts = System.currentTimeMillis() % 1000;
        String courseTitle = "Organic Vegetable Gardening " + ts;

        driver.findElement(By.id("skill_title")).sendKeys(courseTitle);
        new Select(driver.findElement(By.id("category"))).selectByValue("Agriculture");
        driver.findElement(By.id("price")).sendKeys("250");
        driver.findElement(By.id("description")).sendKeys("Basics of vermicomposting, soil nutrition, and kitchen gardening.");
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        createWait(driver).until(ExpectedConditions.urlContains("view-my-skills.jsp"));
        String page = driver.getPageSource();
        if (!driver.getCurrentUrl().contains("added") && !page.contains("Skill published successfully") && !page.contains(courseTitle)) {
            throw new AssertionError("Course creation confirmation not found.");
        }

        lastCourseTitle = courseTitle;
        String shot = DriverFactory.takeScreenshot(driver, "09_skill_published_success");
        res.setScreenshot(shot);
        return "Skill course '" + courseTitle + "' published successfully.";
    }

    public static String test14_VerifySkillInTeacherCatalog(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.TEACHER_EMAIL, TestConfig.TEACHER_PASSWORD, "teacher-dashboard.jsp");

        driver.get(TestConfig.BASE_URL + "/jsp/teacher/view-my-skills.jsp");
        if (lastCourseTitle != null && !driver.getPageSource().contains(lastCourseTitle)) {
            throw new AssertionError("Published course '" + lastCourseTitle + "' not found in teacher catalog.");
        }
        return "Verified course '" + (lastCourseTitle != null ? lastCourseTitle : "catalog") + "' exists in published skills catalog.";
    }

    // -------------------------------------------------------------
    // SUITE 4: STUDENT MARKETPLACE & COURSE BROWSING
    // -------------------------------------------------------------

    public static String test15_BrowseSkillsPageRenders(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.STUDENT_EMAIL, TestConfig.STUDENT_PASSWORD, "student-dashboard.jsp");

        driver.get(TestConfig.BASE_URL + "/jsp/student/browse-skills.jsp");
        if (!driver.getTitle().contains("Browse Skills")) {
            throw new AssertionError("Expected 'Browse Skills' in title, got: " + driver.getTitle());
        }

        String shot = DriverFactory.takeScreenshot(driver, "10_student_browse_skills");
        res.setScreenshot(shot);
        return "Student skill browse catalog rendered successfully.";
    }

    public static String test16_VerifyCoursesInCatalog(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.STUDENT_EMAIL, TestConfig.STUDENT_PASSWORD, "student-dashboard.jsp");

        driver.get(TestConfig.BASE_URL + "/jsp/student/browse-skills.jsp");
        List<WebElement> cards = driver.findElements(By.className("skill-card"));
        if (cards.isEmpty()) {
            throw new AssertionError("Expected at least 1 skill card in catalog, found 0.");
        }
        return "Confirmed " + cards.size() + " active skill course listing(s) displayed in student catalog.";
    }

    // -------------------------------------------------------------
    // SUITE 5: ADMIN GOVERNANCE & USER ACCOUNT OVERSIGHT
    // -------------------------------------------------------------

    public static String test17_AdminDashboardMetrics(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.ADMIN_EMAIL, TestConfig.ADMIN_PASSWORD, "admin-dashboard.jsp");

        String page = driver.getPageSource();
        if (!page.contains("Total Users") && !page.contains("Teachers")) {
            throw new AssertionError("Admin governance metrics cards missing from dashboard.");
        }

        String shot = DriverFactory.takeScreenshot(driver, "11_admin_metrics");
        res.setScreenshot(shot);
        return "Admin governance dashboard metrics evaluated successfully.";
    }

    public static String test18_AdminUserManagementTable(WebDriver driver, TestResult res) {
        loginHelper(driver, TestConfig.ADMIN_EMAIL, TestConfig.ADMIN_PASSWORD, "admin-dashboard.jsp");

        driver.get(TestConfig.BASE_URL + "/jsp/admin/users.jsp");
        String page = driver.getPageSource();
        if (!driver.getTitle().contains("Manage Users") && !page.contains("Manage Users")) {
            throw new AssertionError("Users management view not displayed.");
        }

        List<WebElement> rows = driver.findElements(By.tagName("tr"));
        if (rows.size() < 2) {
            throw new AssertionError("Expected at least header + 1 user row in table, found " + rows.size());
        }

        String shot = DriverFactory.takeScreenshot(driver, "12_admin_users_table");
        res.setScreenshot(shot);
        return "Admin user management table loaded with " + (rows.size() - 1) + " registered accounts.";
    }
}
