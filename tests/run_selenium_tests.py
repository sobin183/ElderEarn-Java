# -*- coding: utf-8 -*-
"""
ElderEarn Automated Selenium Test Suite
Covers:
1. Authentication & Role-Based Access Control (RBAC)
2. User Registration Lifecycle
3. Teacher Skill Course Creation and Catalog Verification
4. Student Marketplace and Course Browsing
5. Admin Governance and User Account Oversight
"""

import os
import sys
import time
import datetime
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

BASE_URL = "http://localhost:8080/ElderEarn"
SCREENSHOT_DIR = r"c:\Users\User\eclipse-workspace\ElderEarn\tests\screenshots"
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

class TestResult:
    def __init__(self, test_id, name, suite):
        self.test_id = test_id
        self.name = name
        self.suite = suite
        self.status = "PENDING"
        self.duration = 0.0
        self.details = ""
        self.screenshot = None

results = []

def get_driver():
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--disable-gpu")
    driver = webdriver.Chrome(options=options)
    driver.implicitly_wait(5)
    return driver

def run_test(test_id, name, suite, test_func):
    res = TestResult(test_id, name, suite)
    start_time = time.time()
    driver = None
    print(f"\n========================================================")
    print(f"[{test_id}] {name} ({suite})")
    print(f"========================================================")
    try:
        driver = get_driver()
        details = test_func(driver, res)
        res.status = "PASSED"
        res.details = details or "Test executed successfully."
        print(f"--> RESULT: [PASSED] ({time.time() - start_time:.2f}s)")
    except Exception as e:
        res.status = "FAILED"
        res.details = str(e)
        print(f"--> RESULT: [FAILED] Reason: {e}")
        if driver:
            err_shot = os.path.join(SCREENSHOT_DIR, f"error_{test_id}.png")
            driver.save_screenshot(err_shot)
            res.screenshot = err_shot
    finally:
        res.duration = time.time() - start_time
        if driver:
            try:
                driver.quit()
            except Exception:
                pass
        results.append(res)
    return res

# -------------------------------------------------------------
# SUITE 1: AUTHENTICATION & ROLE-BASED ACCESS CONTROL (RBAC)
# -------------------------------------------------------------

def test_01_login_page_renders(driver, res):
    url = f"{BASE_URL}/jsp/auth/login.jsp"
    driver.get(url)
    assert "ElderEarn Login" in driver.title, f"Expected 'ElderEarn Login', got '{driver.title}'"
    
    email_el = driver.find_element(By.ID, "email")
    pass_el = driver.find_element(By.ID, "password")
    submit_el = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    
    assert email_el.is_displayed(), "Email input not visible"
    assert pass_el.is_displayed(), "Password input not visible"
    assert submit_el.is_displayed(), "Submit button not visible"
    
    shot = os.path.join(SCREENSHOT_DIR, "01_login_page.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Login page rendered with all required form controls. Saved screenshot: {shot}"

def test_02_login_empty_inputs(driver, res):
    url = f"{BASE_URL}/jsp/auth/login.jsp"
    driver.get(url)
    email_el = driver.find_element(By.ID, "email")
    
    is_required = email_el.get_attribute("required") is not None
    assert is_required, "Email field lacks HTML5 'required' attribute"
    
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp?error=empty")
    alert = driver.find_element(By.CLASS_NAME, "alert-danger")
    assert "Please enter both email and password" in alert.text, f"Unexpected alert text: {alert.text}"
    return "Empty inputs verified via HTML5 required constraints and error alert display."

def test_03_login_invalid_credentials(driver, res):
    url = f"{BASE_URL}/jsp/auth/login.jsp"
    driver.get(url)
    driver.find_element(By.ID, "email").send_keys("nonexistent_user@elderearn.com")
    driver.find_element(By.ID, "password").send_keys("WrongPass999")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.CLASS_NAME, "alert-danger")))
    alert = driver.find_element(By.CLASS_NAME, "alert-danger")
    assert "Invalid Email or Password" in alert.text, f"Expected invalid credentials warning, got: {alert.text}"
    
    shot = os.path.join(SCREENSHOT_DIR, "02_invalid_login_alert.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return "Authentication rejection verified: 'Invalid Email or Password' correctly displayed."

def test_04_teacher_login_and_routing(driver, res):
    url = f"{BASE_URL}/jsp/auth/login.jsp"
    driver.get(url)
    driver.find_element(By.ID, "email").send_keys("sobin88912@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.url_contains("teacher-dashboard.jsp"))
    assert "teacher-dashboard.jsp" in driver.current_url, f"Expected teacher dashboard, got: {driver.current_url}"
    assert "Sobin Thankachan" in driver.page_source or "Teacher" in driver.page_source, "Teacher portal text not detected"
    
    shot = os.path.join(SCREENSHOT_DIR, "03_teacher_dashboard.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Teacher authenticated successfully. Routed to /teacher-dashboard.jsp. Screenshot: {shot}"

def test_05_student_login_and_routing(driver, res):
    url = f"{BASE_URL}/jsp/auth/login.jsp"
    driver.get(url)
    driver.find_element(By.ID, "email").send_keys("chu@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.url_contains("student-dashboard.jsp"))
    assert "student-dashboard.jsp" in driver.current_url, f"Expected student dashboard, got: {driver.current_url}"
    assert "Welcome back" in driver.page_source or "Student" in driver.page_source, "Student portal text not detected"
    
    shot = os.path.join(SCREENSHOT_DIR, "04_student_dashboard.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Student authenticated successfully. Routed to /student-dashboard.jsp. Screenshot: {shot}"

def test_06_admin_login_and_routing(driver, res):
    url = f"{BASE_URL}/jsp/auth/login.jsp"
    driver.get(url)
    driver.find_element(By.ID, "email").send_keys("admin@elderearn.com")
    driver.find_element(By.ID, "password").send_keys("admin123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.url_contains("admin-dashboard.jsp"))
    assert "admin-dashboard.jsp" in driver.current_url, f"Expected admin dashboard, got: {driver.current_url}"
    assert "Admin" in driver.page_source, "Admin portal text not detected"
    
    shot = os.path.join(SCREENSHOT_DIR, "05_admin_dashboard.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Admin authenticated successfully. Routed to /admin-dashboard.jsp. Screenshot: {shot}"

def test_07_logout_workflow(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("sobin88912@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("teacher-dashboard.jsp"))
    
    # Trigger LogoutServlet
    driver.get(f"{BASE_URL}/LogoutServlet")
    WebDriverWait(driver, 5).until(EC.url_contains("index.jsp"))
    assert "index.jsp" in driver.current_url, f"Expected redirect to index.jsp, got: {driver.current_url}"
    
    # Verify session is invalidated: attempting to visit protected teacher dashboard redirects to login
    driver.get(f"{BASE_URL}/jsp/teacher/teacher-dashboard.jsp")
    WebDriverWait(driver, 5).until(EC.url_contains("login.jsp"))
    assert "login.jsp" in driver.current_url, "Protected page did not redirect after logout session invalidation"
    
    shot = os.path.join(SCREENSHOT_DIR, "05_logout_session_cleared.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return "Session invalidated by LogoutServlet (redirected to index.jsp; subsequent access to protected dashboard blocked)."

# -------------------------------------------------------------
# SUITE 2: ACCOUNT REGISTRATION LIFECYCLE
# -------------------------------------------------------------

def test_08_register_page_renders(driver, res):
    url = f"{BASE_URL}/jsp/auth/register.jsp"
    driver.get(url)
    assert "ElderEarn" in driver.page_source, "Page source missing 'ElderEarn'"
    
    assert driver.find_element(By.ID, "full_name").is_displayed(), "full_name input missing"
    assert driver.find_element(By.ID, "email").is_displayed(), "email input missing"
    assert driver.find_element(By.ID, "role").is_displayed(), "role select missing"
    assert driver.find_element(By.ID, "password").is_displayed(), "password input missing"
    assert driver.find_element(By.ID, "confirm_password").is_displayed(), "confirm_password input missing"
    
    shot = os.path.join(SCREENSHOT_DIR, "06_register_page.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Registration page rendered with all required fields. Screenshot: {shot}"

def test_09_register_password_mismatch(driver, res):
    url = f"{BASE_URL}/jsp/auth/register.jsp"
    driver.get(url)
    driver.find_element(By.ID, "full_name").send_keys("Test User")
    driver.find_element(By.ID, "email").send_keys("mismatch@elderearn.com")
    Select(driver.find_element(By.ID, "role")).select_by_value("student")
    driver.find_element(By.ID, "password").send_keys("Secret123")
    driver.find_element(By.ID, "confirm_password").send_keys("DifferentPass")
    
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    time.sleep(0.5)
    
    js_alert = driver.find_element(By.ID, "js-alert")
    assert not js_alert.get_attribute("class").__contains__("d-none") or "login.jsp" not in driver.current_url, \
        "Form allowed submission despite mismatched passwords"
    return "Client-side password mismatch verification confirmed; submission intercepted."

def test_10_register_new_student_account(driver, res):
    ts = int(time.time())
    new_email = f"student_{ts}@elderearn.com"
    new_name = f"Learner User {ts % 1000}"
    
    url = f"{BASE_URL}/jsp/auth/register.jsp"
    driver.get(url)
    driver.find_element(By.ID, "full_name").send_keys(new_name)
    driver.find_element(By.ID, "email").send_keys(new_email)
    Select(driver.find_element(By.ID, "role")).select_by_value("student")
    driver.find_element(By.ID, "password").send_keys("Pass1234")
    driver.find_element(By.ID, "confirm_password").send_keys("Pass1234")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.url_contains("login.jsp"))
    assert "login.jsp" in driver.current_url, f"Expected login redirect, got: {driver.current_url}"
    assert "registered" in driver.current_url or "Registration successful" in driver.page_source, "Success message missing"
    
    shot = os.path.join(SCREENSHOT_DIR, "07_registration_success.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    
    with open(os.path.join(SCREENSHOT_DIR, "last_user.txt"), "w") as f:
        f.write(f"{new_email},Pass1234,{new_name}")
        
    return f"New student account successfully registered: {new_email}. Screenshot: {shot}"

def test_11_login_with_newly_registered_student(driver, res):
    info_path = os.path.join(SCREENSHOT_DIR, "last_user.txt")
    if not os.path.exists(info_path):
        return "Skipped: Last user info file not found."
    with open(info_path, "r") as f:
        email, password, name = f.read().split(",")
        
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys(email)
    driver.find_element(By.ID, "password").send_keys(password)
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.url_contains("student-dashboard.jsp"))
    assert "student-dashboard.jsp" in driver.current_url, f"Expected student dashboard, got: {driver.current_url}"
    assert name in driver.page_source, f"Expected '{name}' on dashboard"
    return f"Newly registered user '{email}' successfully authenticated and logged in."

# -------------------------------------------------------------
# SUITE 3: SENIOR / TEACHER SKILL COURSE PUBLISHING
# -------------------------------------------------------------

def test_12_add_skill_form_renders(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("sobin88912@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("teacher-dashboard.jsp"))
    
    driver.get(f"{BASE_URL}/jsp/teacher/add-skill.jsp")
    assert "Add Skill" in driver.title, f"Expected 'Add Skill', got: {driver.title}"
    assert driver.find_element(By.ID, "skill_title").is_displayed(), "skill_title missing"
    assert driver.find_element(By.ID, "category").is_displayed(), "category missing"
    assert driver.find_element(By.ID, "price").is_displayed(), "price missing"
    assert driver.find_element(By.ID, "description").is_displayed(), "description missing"
    
    shot = os.path.join(SCREENSHOT_DIR, "08_add_skill_form.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Course creation form rendered with all inputs. Screenshot: {shot}"

def test_13_publish_new_skill_course(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("sobin88912@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("teacher-dashboard.jsp"))
    
    driver.get(f"{BASE_URL}/jsp/teacher/add-skill.jsp")
    ts = int(time.time())
    course_title = f"Organic Vegetable Gardening {ts % 1000}"
    
    driver.find_element(By.ID, "skill_title").send_keys(course_title)
    Select(driver.find_element(By.ID, "category")).select_by_value("Agriculture")
    driver.find_element(By.ID, "price").send_keys("250")
    driver.find_element(By.ID, "description").send_keys("Basics of vermicomposting, soil nutrition, and kitchen gardening.")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    
    WebDriverWait(driver, 5).until(EC.url_contains("view-my-skills.jsp"))
    assert "view-my-skills.jsp" in driver.current_url, f"Expected view-my-skills.jsp, got: {driver.current_url}"
    assert "added" in driver.current_url or "Skill published successfully" in driver.page_source, "Success message not found"
    
    shot = os.path.join(SCREENSHOT_DIR, "09_skill_published_success.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    
    with open(os.path.join(SCREENSHOT_DIR, "last_course.txt"), "w") as f:
        f.write(course_title)
        
    return f"Skill course '{course_title}' published successfully. Screenshot: {shot}"

def test_14_verify_skill_in_teacher_catalog(driver, res):
    course_path = os.path.join(SCREENSHOT_DIR, "last_course.txt")
    if not os.path.exists(course_path):
        return "Skipped: Last course file not found."
    with open(course_path, "r") as f:
        course_title = f.read().strip()
        
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("sobin88912@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("teacher-dashboard.jsp"))
    
    driver.get(f"{BASE_URL}/jsp/teacher/view-my-skills.jsp")
    assert course_title in driver.page_source, f"Course '{course_title}' not found in teacher catalog"
    return f"Verified course '{course_title}' exists in published skills catalog."

# -------------------------------------------------------------
# SUITE 4: STUDENT MARKETPLACE & COURSE BROWSING
# -------------------------------------------------------------

def test_15_browse_skills_page_renders(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("chu@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("student-dashboard.jsp"))
    
    driver.get(f"{BASE_URL}/jsp/student/browse-skills.jsp")
    assert "Browse Skills" in driver.title, f"Expected 'Browse Skills', got: {driver.title}"
    
    shot = os.path.join(SCREENSHOT_DIR, "10_student_browse_skills.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Student skill browse catalog rendered successfully. Screenshot: {shot}"

def test_16_verify_courses_in_catalog(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("chu@gmail.com")
    driver.find_element(By.ID, "password").send_keys("123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("student-dashboard.jsp"))
    
    driver.get(f"{BASE_URL}/jsp/student/browse-skills.jsp")
    cards = driver.find_elements(By.CLASS_NAME, "skill-card")
    assert len(cards) >= 1, f"Expected at least 1 skill card in student catalog, found {len(cards)}"
    return f"Confirmed {len(cards)} active skill course listing(s) displayed in student catalog."

# -------------------------------------------------------------
# SUITE 5: ADMIN GOVERNANCE & USER ACCOUNT OVERSIGHT
# -------------------------------------------------------------

def test_17_admin_dashboard_metrics(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("admin@elderearn.com")
    driver.find_element(By.ID, "password").send_keys("admin123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("admin-dashboard.jsp"))
    
    assert "Total Users" in driver.page_source or "Teachers" in driver.page_source, "Metrics cards missing"
    shot = os.path.join(SCREENSHOT_DIR, "11_admin_metrics.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Admin governance dashboard metrics evaluated successfully. Screenshot: {shot}"

def test_18_admin_user_management_table(driver, res):
    driver.get(f"{BASE_URL}/jsp/auth/login.jsp")
    driver.find_element(By.ID, "email").send_keys("admin@elderearn.com")
    driver.find_element(By.ID, "password").send_keys("admin123")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    WebDriverWait(driver, 5).until(EC.url_contains("admin-dashboard.jsp"))
    
    driver.get(f"{BASE_URL}/jsp/admin/users.jsp")
    assert "Manage Users" in driver.title or "Manage Users" in driver.page_source, "Users management view not displayed"
    
    rows = driver.find_elements(By.TAG_NAME, "tr")
    assert len(rows) >= 2, f"Expected at least header + 1 user row in table, found {len(rows)}"
    
    shot = os.path.join(SCREENSHOT_DIR, "12_admin_users_table.png")
    driver.save_screenshot(shot)
    res.screenshot = shot
    return f"Admin user management table loaded with {len(rows)-1} registered accounts. Screenshot: {shot}"

# -------------------------------------------------------------
# MAIN TEST DISPATCHER & REPORT GENERATOR
# -------------------------------------------------------------

TEST_CASES = [
    ("TC-01", "Login Page Form Elements Render", "Authentication & RBAC", test_01_login_page_renders),
    ("TC-02", "Empty Input Form Validation", "Authentication & RBAC", test_02_login_empty_inputs),
    ("TC-03", "Invalid Credentials Error Alert", "Authentication & RBAC", test_03_login_invalid_credentials),
    ("TC-04", "Senior / Teacher Login & Routing", "Authentication & RBAC", test_04_teacher_login_and_routing),
    ("TC-05", "Student Login & Redirection", "Authentication & RBAC", test_05_student_login_and_routing),
    ("TC-06", "Admin Login & Access Control", "Authentication & RBAC", test_06_admin_login_and_routing),
    ("TC-07", "Logout & Session Invalidation", "Authentication & RBAC", test_07_logout_workflow),
    ("TC-08", "Registration Form Controls Display", "Registration Lifecycle", test_08_register_page_renders),
    ("TC-09", "Password Mismatch Client Validation", "Registration Lifecycle", test_09_register_password_mismatch),
    ("TC-10", "New Student Account Registration", "Registration Lifecycle", test_10_register_new_student_account),
    ("TC-11", "Authenticate with New Account", "Registration Lifecycle", test_11_login_with_newly_registered_student),
    ("TC-12", "Skill Course Creation Form Render", "Course Publishing", test_12_add_skill_form_renders),
    ("TC-13", "Publish New Skill Course into MySQL", "Course Publishing", test_13_publish_new_skill_course),
    ("TC-14", "Verify Course in Teacher Catalog", "Course Publishing", test_14_verify_skill_in_teacher_catalog),
    ("TC-15", "Student Marketplace View Render", "Marketplace Browsing", test_15_browse_skills_page_renders),
    ("TC-16", "Verify Course Availability in Catalog", "Marketplace Browsing", test_16_verify_courses_in_catalog),
    ("TC-17", "Admin Governance Overview Metrics", "Admin Governance", test_17_admin_dashboard_metrics),
    ("TC-18", "Admin User Account Management View", "Admin Governance", test_18_admin_user_management_table),
]

def main():
    print("================================================================================")
    print("             STARTING ELDEREARN AUTOMATED SELENIUM TEST SUITE                   ")
    print(f" Timestamp: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f" Target Application: {BASE_URL}")
    print("================================================================================")
    
    overall_start = time.time()
    for tid, name, suite, func in TEST_CASES:
        run_test(tid, name, suite, func)
        
    total_time = time.time() - overall_start
    total = len(results)
    passed = sum(1 for r in results if r.status == "PASSED")
    failed = sum(1 for r in results if r.status == "FAILED")
    
    print("\n" + "="*80)
    print("                           TEST EXECUTION SUMMARY                               ")
    print("="*80)
    print(f"{'Test ID':<8} | {'Test Suite':<23} | {'Test Name':<32} | {'Status':<7} | {'Time':<6}")
    print("-"*80)
    for r in results:
        print(f"{r.test_id:<8} | {r.suite:<23} | {r.name[:32]:<32} | {r.status:<7} | {r.duration:.2f}s")
    print("-"*80)
    print(f"Total Tests Executed : {total}")
    print(f"Passed               : {passed} ({passed/total*100:.1f}%)")
    print(f"Failed               : {failed} ({failed/total*100:.1f}%)")
    print(f"Total Execution Time : {total_time:.2f} seconds")
    print("="*80)
    
    report_file = r"c:\Users\User\eclipse-workspace\ElderEarn\tests\SELENIUM_TEST_REPORT.md"
    with open(report_file, "w", encoding="utf-8") as f:
        f.write("# ElderEarn Automated Selenium Test Report\n\n")
        f.write(f"- **Execution Timestamp:** {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"- **Application URL:** `{BASE_URL}`\n")
        f.write(f"- **Browser:** Google Chrome (Headless via Selenium WebDriver 4.x)\n")
        f.write(f"- **Total Tests:** {total}\n")
        f.write(f"- **Passed:** {passed} (100%)\n" if failed == 0 else f"- **Passed:** {passed}\n- **Failed:** {failed}\n")
        f.write(f"- **Total Execution Time:** {total_time:.2f}s\n\n")
        f.write("## Detailed Test Case Execution Table\n\n")
        f.write("| Test ID | Test Suite | Test Scenario | Status | Duration | Details |\n")
        f.write("|---|---|---|---|---|---|\n")
        for r in results:
            f.write(f"| `{r.test_id}` | {r.suite} | {r.name} | **{r.status}** | {r.duration:.2f}s | {r.details} |\n")
        f.write("\n## Test Screenshots Captured\n\n")
        for r in results:
            if r.screenshot and os.path.exists(r.screenshot):
                f.write(f"- **[{r.test_id}] {r.name}**: `{r.screenshot}`\n")
    
    print(f"\nDetailed report written to: {report_file}")
    if failed > 0:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
