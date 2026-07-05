<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "browse-skills");
    String studentName = (String) session.getAttribute("full_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Skills - ElderEarn</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
    
    <style>
        .skill-card {
            border: none;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            transition: all 0.3s;
            height: 100%;
            display: flex;
            flex-column: column;
            background-color: var(--white);
        }

        .skill-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(15, 76, 129, 0.08);
        }

        .skill-icon-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background-color: var(--sky-blue);
            color: var(--primary-blue);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center mb-4 gap-3">
                <div>
                    <h2 class="fw-bold mb-1">Browse Skills & Courses</h2>
                    <p class="text-muted mb-0">Learn directly from retired specialists, trade craftsmen, and local professionals.</p>
                </div>
            </div>

            <!-- Search and Filter Panel -->
            <div class="content-card py-3 mb-4">
                <form action="browse-skills.jsp" method="get" class="row g-3">
                    <div class="col-md-6 col-lg-5">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search by title, teacher, or description..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                        </div>
                    </div>
                    <div class="col-md-4 col-lg-4">
                        <select name="category" class="form-select">
                            <option value="">All Categories</option>
                            <%
                                String[] cats = {"Technology", "Music", "Arts & Crafts", "Cooking", "Languages", "Business", "Tuition", "Fitness & Yoga", "Agriculture", "Handicrafts"};
                                String currentCat = request.getParameter("category");
                                for (String c : cats) {
                            %>
                                <option value="<%= c %>" <%= c.equals(currentCat) ? "selected" : "" %>><%= c %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-2 col-lg-3 d-flex gap-2">
                        <button type="submit" class="btn btn-custom btn-custom-primary w-100"><i class="bi bi-funnel-fill me-1"></i> Filter</button>
                        <a href="browse-skills.jsp" class="btn btn-light border"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Skill Cards Grid -->
            <div class="row g-4">
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        String search = request.getParameter("search");
                        String category = request.getParameter("category");
                        
                        String sql = "SELECT * FROM skills WHERE 1=1";
                        if (search != null && !search.trim().isEmpty()) {
                            sql += " AND (skill_title LIKE ? OR teacher_name LIKE ? OR description LIKE ?)";
                        }
                        if (category != null && !category.trim().isEmpty()) {
                            sql += " AND category = ?";
                        }
                        sql += " ORDER BY skill_id DESC";
                        
                        PreparedStatement ps = conn.prepareStatement(sql);
                        int idx = 1;
                        if (search != null && !search.trim().isEmpty()) {
                            String pattern = "%" + search.trim() + "%";
                            ps.setString(idx++, pattern);
                            ps.setString(idx++, pattern);
                            ps.setString(idx++, pattern);
                        }
                        if (category != null && !category.trim().isEmpty()) {
                            ps.setString(idx++, category.trim());
                        }
                        
                        ResultSet rs = ps.executeQuery();
                        boolean hasSkills = false;
                        while (rs.next()) {
                            hasSkills = true;
                            int skillId = rs.getInt("skill_id");
                            String title = rs.getString("skill_title");
                            String teacher = rs.getString("teacher_name");
                            if (teacher == null) teacher = "Anonymous Expert";
                            String cat = rs.getString("category");
                            String price = rs.getString("price");
                            String description = rs.getString("description");
                            
                            // Avatar initials
                            String initials = "";
                            if (teacher.length() > 0) {
                                String[] parts = teacher.split(" ");
                                for(int i=0; i<Math.min(parts.length, 2); i++) {
                                    if(parts[i].length() > 0) initials += parts[i].substring(0,1).toUpperCase();
                                }
                            }
                %>
                <div class="col-md-6 col-lg-4">
                    <div class="skill-card card">
                        <div class="card-body d-flex flex-column justify-content-between p-4">
                            <div>
                                <div class="d-flex align-items-center gap-3 mb-3">
                                    <div class="skill-icon-avatar"><%= initials %></div>
                                    <div>
                                        <a href="teacher-profile.jsp?teacher=<%= java.net.URLEncoder.encode(teacher, "UTF-8") %>" class="fw-bold mb-0 text-primary text-decoration-none hover-underline"><%= teacher %></a>
                                        <span class="small text-muted d-block"><i class="bi bi-patch-check-fill text-primary"></i> Senior Specialist</span>
                                    </div>
                                </div>
                                <h4 class="fw-bold mb-2 text-dark"><%= title %></h4>
                                <span class="badge bg-primary-tint text-primary px-2.5 py-1.5 mb-3"><%= cat %></span>
                                <p class="text-muted small mb-4">
                                    <%= description.length() > 140 ? description.substring(0, 137) + "..." : description %>
                                </p>
                            </div>
                            
                            <div>
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="text-muted small">Subscription Plan</span>
                                    <h4 class="fw-bold text-success mb-0">₹<%= price %> <span class="fs-6 fw-normal text-muted">/mo</span></h4>
                                </div>
                                <div class="row g-2">
                                    <div class="col-6">
                                        <!-- View Details Modal Trigger -->
                                        <button type="button" class="btn btn-outline-primary w-100 btn-custom-sm" data-bs-toggle="modal" data-bs-target="#skillModal<%= skillId %>">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="col-6">
                                        <a href="checkout.jsp?item_type=skill&item_id=<%= skillId %>" class="btn btn-primary w-100 btn-custom-sm">Subscribe</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Skill Details Modal -->
                <div class="modal fade" id="skillModal<%= skillId %>" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content rounded-4 border-0 shadow">
                            <div class="modal-header border-0 pb-0">
                                <button type="button" class="btn-close" data-bs-shadow="none" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body px-4 pb-4 pt-0">
                                <div class="text-center mb-4">
                                    <div class="skill-icon-avatar mx-auto mb-3" style="width:60px; height:60px; font-size:1.5rem;"><%= initials %></div>
                                    <h4 class="fw-bold mb-1"><%= title %></h4>
                                    <p class="text-muted small">Taught by <span class="fw-bold"><%= teacher %></span></p>
                                    <span class="badge bg-primary-tint text-primary px-3 py-1.5 rounded-pill"><%= cat %></span>
                                </div>
                                
                                <h6 class="fw-bold mb-2">About this Course</h6>
                                <p class="text-muted small mb-4" style="line-height:1.6; white-space: pre-wrap;"><%= description %></p>
                                
                                <div class="bg-light p-3 rounded-4 d-flex justify-content-between align-items-center mb-4">
                                    <div>
                                        <span class="small text-muted d-block">Monthly Subscription</span>
                                        <span class="fw-bold text-success fs-5">₹<%= price %>/month</span>
                                    </div>
                                    <span class="small text-muted"><i class="bi bi-shield-fill-check text-success"></i> Secured Payment</span>
                                </div>
                                
                                <div class="d-flex gap-2">
                                    <a href="checkout.jsp?item_type=skill&item_id=<%= skillId %>" class="btn btn-primary w-100 btn-custom">Subscribe Now</a>
                                    <button type="button" class="btn btn-light border w-100 btn-custom" data-bs-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%
                        }
                        rs.close();
                        ps.close();
                        conn.close();
                        
                        if (!hasSkills) {
                %>
                <div class="col-12 text-center text-muted py-5">
                    <i class="bi bi-patch-question fs-1 d-block mb-3"></i>
                    No skills matched your search queries. Try choosing another category or keyword.
                </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                <div class="col-12 text-center text-danger py-4">Database load error.</div>
                <%
                    }
                %>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
