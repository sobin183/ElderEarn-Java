<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String teacherName = (String) session.getAttribute("full_name");
    String teacherRole = (String) session.getAttribute("role");
    if (teacherName == null || !"teacher".equals(teacherRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "add-skill");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Skill - Teacher Portal</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Add New Skill Course</h2>
                    <p class="text-muted mb-0">Publish a new learning subject to get active subscribers.</p>
                </div>
            </div>

            <!-- Error Alerts -->
            <%
                String error = request.getParameter("error");
                if ("empty".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> All fields are required. Please check your inputs.
                </div>
            <%
                } else if ("db_error".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Database error occurred. Please try again.
                </div>
            <%
                }
            %>

            <!-- Form Card -->
            <div class="row">
                <div class="col-lg-8">
                    <div class="content-card">
                        <form action="../../AddSkillServlet" method="post">
                            <div class="mb-4">
                                <label for="skill_title" class="form-label fw-bold">Skill Title</label>
                                <input type="text" id="skill_title" name="skill_title" class="form-control" placeholder="e.g. Master the Guitar: Beginner to Advanced" required>
                                <div class="form-text">Choose a descriptive and catchy title for your course.</div>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label for="category" class="form-label fw-bold">Category</label>
                                    <select id="category" name="category" class="form-select" required>
                                        <option value="">Select Category</option>
                                        <option value="Technology">Technology</option>
                                        <option value="Music">Music</option>
                                        <option value="Arts & Crafts">Arts & Crafts</option>
                                        <option value="Cooking">Cooking</option>
                                        <option value="Languages">Languages</option>
                                        <option value="Business">Business</option>
                                        <option value="Tuition">Tuition</option>
                                        <option value="Fitness & Yoga">Fitness & Yoga</option>
                                        <option value="Agriculture">Agriculture</option>
                                        <option value="Handicrafts">Handicrafts</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="price" class="form-label fw-bold">Price (₹ per Month)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light text-muted">₹</span>
                                        <input type="number" id="price" name="price" min="0" step="1" class="form-control" placeholder="500" required>
                                    </div>
                                    <div class="form-text">Set an affordable monthly subscription price.</div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label fw-bold">Detailed Description</label>
                                <textarea id="description" name="description" class="form-control" rows="6" placeholder="Describe the topics covered, scheduling details, requirements, and target audience..." required></textarea>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-custom btn-custom-primary px-4"><i class="bi bi-cloud-arrow-up-fill me-1"></i> Publish Skill</button>
                                <a href="view-my-skills.jsp" class="btn btn-light border px-4">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div class="col-lg-4">
                    <div class="content-card bg-sky-blue border-0">
                        <h5 class="fw-bold text-primary mb-3"><i class="bi bi-lightbulb-fill"></i> Publishing Tips</h5>
                        <ul class="list-unstyled mb-0 text-muted small">
                            <li class="mb-3 d-flex align-items-start gap-2">
                                <i class="bi bi-check-circle text-primary mt-0.5"></i>
                                <span><strong>Catchy Title:</strong> Mention both the core skill and target level in the title (e.g., "Intermediate French Conversation").</span>
                            </li>
                            <li class="mb-3 d-flex align-items-start gap-2">
                                <i class="bi bi-check-circle text-primary mt-0.5"></i>
                                <span><strong>Affordable Price:</strong> Subscriptions are monthly, so price it reasonably to encourage long-term student signups.</span>
                            </li>
                            <li class="mb-0 d-flex align-items-start gap-2">
                                <i class="bi bi-check-circle text-primary mt-0.5"></i>
                                <span><strong>Clear Description:</strong> List any prerequisite materials (e.g., "Must own a standard acoustic guitar").</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
