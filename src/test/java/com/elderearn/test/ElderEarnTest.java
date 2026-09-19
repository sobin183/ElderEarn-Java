package com.elderearn.test;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.WebDriver;

public class ElderEarnTest {

    public interface TestExecutable {
        String execute(WebDriver driver, TestResult res) throws Exception;
    }

    public static class TestCase {
        public final String id;
        public final String name;
        public final String suite;
        public final TestExecutable executable;

        public TestCase(String id, String name, String suite, TestExecutable executable) {
            this.id = id;
            this.name = name;
            this.suite = suite;
            this.executable = executable;
        }
    }

    public static void main(String[] args) {
        System.out.println("================================================================================");
        System.out.println("             ELDEREARN AUTOMATED SELENIUM TEST SUITE (JAVA)                     ");
        System.out.println(" Target Application: " + TestConfig.BASE_URL);
        System.out.println(" Timestamp: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        System.out.println(" Headless Mode: " + TestConfig.HEADLESS);
        System.out.println("================================================================================\n");

        List<TestCase> tests = getTestCases();
        List<TestResult> results = new ArrayList<>();

        long overallStart = System.currentTimeMillis();

        for (TestCase tc : tests) {
            TestResult res = new TestResult(tc.id, tc.name, tc.suite);
            System.out.println("--------------------------------------------------------------------------------");
            System.out.printf("[%s] %s (%s)%n", tc.id, tc.name, tc.suite);
            System.out.println("--------------------------------------------------------------------------------");

            WebDriver driver = null;
            long start = System.currentTimeMillis();
            try {
                driver = DriverFactory.createDriver();
                String details = tc.executable.execute(driver, res);
                if (!"SKIPPED".equals(res.getStatus())) {
                    res.setStatus("PASSED");
                }
                res.setDetails(details);
                double elapsed = (System.currentTimeMillis() - start) / 1000.0;
                res.setDuration(elapsed);
                System.out.printf("--> RESULT: [%s] (%.2fs)%n", res.getStatus(), elapsed);
            } catch (Throwable t) {
                double elapsed = (System.currentTimeMillis() - start) / 1000.0;
                res.setDuration(elapsed);
                res.setStatus("FAILED");
                res.setDetails(t.getMessage() != null ? t.getMessage() : t.toString());
                System.out.printf("--> RESULT: [FAILED] (%.2fs)%n", elapsed);
                System.out.println("    Reason: " + res.getDetails());

                if (driver != null) {
                    String errShot = DriverFactory.takeScreenshot(driver, "error_" + tc.id);
                    res.setScreenshot(errShot);
                }
            } finally {
                DriverFactory.quitDriver(driver);
                results.add(res);
            }
        }

        double totalSeconds = (System.currentTimeMillis() - overallStart) / 1000.0;
        printSummary(results, totalSeconds);
        writeReport(results, totalSeconds);
    }

    private static List<TestCase> getTestCases() {
        List<TestCase> list = new ArrayList<>();

        // Suite 1: Authentication & RBAC
        list.add(new TestCase("TC-01", "Login Page Form Elements Render", "Authentication & RBAC", ElderEarnTestSuite::test01_LoginPageRenders));
        list.add(new TestCase("TC-02", "Empty Input Form Validation", "Authentication & RBAC", ElderEarnTestSuite::test02_LoginEmptyInputs));
        list.add(new TestCase("TC-03", "Invalid Credentials Error Alert", "Authentication & RBAC", ElderEarnTestSuite::test03_LoginInvalidCredentials));
        list.add(new TestCase("TC-04", "Senior / Teacher Login & Routing", "Authentication & RBAC", ElderEarnTestSuite::test04_TeacherLoginAndRouting));
        list.add(new TestCase("TC-05", "Student Login & Redirection", "Authentication & RBAC", ElderEarnTestSuite::test05_StudentLoginAndRouting));
        list.add(new TestCase("TC-06", "Admin Login & Access Control", "Authentication & RBAC", ElderEarnTestSuite::test06_AdminLoginAndRouting));
        list.add(new TestCase("TC-07", "Logout & Session Invalidation", "Authentication & RBAC", ElderEarnTestSuite::test07_LogoutWorkflow));

        // Suite 2: Registration Lifecycle
        list.add(new TestCase("TC-08", "Registration Form Controls Display", "Registration Lifecycle", ElderEarnTestSuite::test08_RegisterPageRenders));
        list.add(new TestCase("TC-09", "Password Mismatch Client Validation", "Registration Lifecycle", ElderEarnTestSuite::test09_RegisterPasswordMismatch));
        list.add(new TestCase("TC-10", "New Student Account Registration", "Registration Lifecycle", ElderEarnTestSuite::test10_RegisterNewStudentAccount));
        list.add(new TestCase("TC-11", "Authenticate with New Account", "Registration Lifecycle", ElderEarnTestSuite::test11_LoginWithNewlyRegisteredStudent));

        // Suite 3: Teacher Skill Course Publishing
        list.add(new TestCase("TC-12", "Skill Course Creation Form Render", "Course Publishing", ElderEarnTestSuite::test12_AddSkillFormRenders));
        list.add(new TestCase("TC-13", "Publish New Skill Course into MySQL", "Course Publishing", ElderEarnTestSuite::test13_PublishNewSkillCourse));
        list.add(new TestCase("TC-14", "Verify Course in Teacher Catalog", "Course Publishing", ElderEarnTestSuite::test14_VerifySkillInTeacherCatalog));

        // Suite 4: Student Marketplace
        list.add(new TestCase("TC-15", "Student Marketplace View Render", "Marketplace Browsing", ElderEarnTestSuite::test15_BrowseSkillsPageRenders));
        list.add(new TestCase("TC-16", "Verify Course Availability in Catalog", "Marketplace Browsing", ElderEarnTestSuite::test16_VerifyCoursesInCatalog));

        // Suite 5: Admin Governance
        list.add(new TestCase("TC-17", "Admin Governance Overview Metrics", "Admin Governance", ElderEarnTestSuite::test17_AdminDashboardMetrics));
        list.add(new TestCase("TC-18", "Admin User Account Management View", "Admin Governance", ElderEarnTestSuite::test18_AdminUserManagementTable));

        return list;
    }

    private static void printSummary(List<TestResult> results, double totalSeconds) {
        int passed = 0;
        int failed = 0;
        int skipped = 0;

        System.out.println("\n================================================================================");
        System.out.println("                           TEST EXECUTION SUMMARY                               ");
        System.out.println("================================================================================");
        System.out.printf("%-7s | %-23s | %-32s | %-7s | %-6s%n", "Test ID", "Test Suite", "Test Name", "Status", "Time");
        System.out.println("--------------------------------------------------------------------------------");

        for (TestResult r : results) {
            String name = r.getName().length() > 32 ? r.getName().substring(0, 29) + "..." : r.getName();
            System.out.printf("%-7s | %-23s | %-32s | %-7s | %.2fs%n",
                    r.getTestId(), r.getSuite(), name, r.getStatus(), r.getDuration());
            if ("PASSED".equals(r.getStatus())) passed++;
            else if ("FAILED".equals(r.getStatus())) failed++;
            else skipped++;
        }

        int total = results.size();
        System.out.println("--------------------------------------------------------------------------------");
        System.out.printf("Total Tests Executed : %d%n", total);
        System.out.printf("Passed               : %d (%.1f%%)%n", passed, (total > 0 ? (passed * 100.0 / total) : 0));
        System.out.printf("Failed               : %d (%.1f%%)%n", failed, (total > 0 ? (failed * 100.0 / total) : 0));
        if (skipped > 0) {
            System.out.printf("Skipped              : %d%n", skipped);
        }
        System.out.printf("Total Execution Time : %.2f seconds%n", totalSeconds);
        System.out.println("================================================================================");
    }

    private static void writeReport(List<TestResult> results, double totalSeconds) {
        File reportFile = new File(System.getProperty("user.dir"), "SELENIUM_TEST_REPORT.md");
        int passed = 0;
        int failed = 0;
        for (TestResult r : results) {
            if ("PASSED".equals(r.getStatus())) passed++;
            else if ("FAILED".equals(r.getStatus())) failed++;
        }

        try (PrintWriter writer = new PrintWriter(new FileWriter(reportFile))) {
            writer.println("# ElderEarn Automated Selenium Test Report (Java)");
            writer.println();
            writer.println("- **Execution Timestamp:** " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            writer.println("- **Application URL:** `" + TestConfig.BASE_URL + "`");
            writer.println("- **Framework:** Java + Selenium WebDriver 4.x (Chrome)");
            writer.println("- **Total Tests:** " + results.size());
            writer.printf("- **Passed:** %d (%.1f%%)%n", passed, (results.size() > 0 ? (passed * 100.0 / results.size()) : 0));
            if (failed > 0) {
                writer.println("- **Failed:** " + failed);
            }
            writer.printf("- **Total Execution Time:** %.2fs%n", totalSeconds);
            writer.println();
            writer.println("## Detailed Test Case Execution Table");
            writer.println();
            writer.println("| Test ID | Test Suite | Test Scenario | Status | Duration | Details |");
            writer.println("|---|---|---|---|---|---|");
            for (TestResult r : results) {
                writer.printf("| `%s` | %s | %s | **%s** | %.2fs | %s |%n",
                        r.getTestId(), r.getSuite(), r.getName(), r.getStatus(), r.getDuration(), r.getDetails());
            }
            writer.println();
            writer.println("## Captured Screenshots");
            writer.println();
            for (TestResult r : results) {
                if (r.getScreenshot() != null) {
                    writer.printf("- **[%s] %s**: `%s`%n", r.getTestId(), r.getName(), r.getScreenshot());
                }
            }
            System.out.println("\nDetailed markdown report generated at: " + reportFile.getAbsolutePath());
        } catch (Exception e) {
            System.err.println("Could not write markdown report: " + e.getMessage());
        }
    }
}
