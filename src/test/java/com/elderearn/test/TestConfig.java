package com.elderearn.test;

import java.io.File;

public class TestConfig {

    public static final String BASE_URL = "http://localhost:8080/ElderEarn";

    // Standard test credentials
    public static final String TEACHER_EMAIL = "sobin88912@gmail.com";
    public static final String TEACHER_PASSWORD = "123";

    public static final String STUDENT_EMAIL = "chu@gmail.com";
    public static final String STUDENT_PASSWORD = "123";

    public static final String ADMIN_EMAIL = "admin@elderearn.com";
    public static final String ADMIN_PASSWORD = "admin123";

    // Timeouts
    public static final int IMPLICIT_WAIT_SECONDS = 5;
    public static final int EXPLICIT_WAIT_SECONDS = 8;

    // Screenshot directory
    public static final String SCREENSHOT_DIR = "c:/Users/User/eclipse-workspace/ElderEarnWeb/screenshots";

    // Headless mode toggle (can be toggled to false to watch browser execution)
    public static boolean HEADLESS = true;
}
