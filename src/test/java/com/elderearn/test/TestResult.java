package com.elderearn.test;

public class TestResult {
    private final String testId;
    private final String name;
    private final String suite;
    private String status = "PENDING";
    private double duration = 0.0;
    private String details = "";
    private String screenshot = null;

    public TestResult(String testId, String name, String suite) {
        this.testId = testId;
        this.name = name;
        this.suite = suite;
    }

    public String getTestId() { return testId; }
    public String getName() { return name; }
    public String getSuite() { return suite; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public double getDuration() { return duration; }
    public void setDuration(double duration) { this.duration = duration; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
    public String getScreenshot() { return screenshot; }
    public void setScreenshot(String screenshot) { this.screenshot = screenshot; }
}
