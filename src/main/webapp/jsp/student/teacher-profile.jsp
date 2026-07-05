<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String studentName = (String) session.getAttribute("full_name");
    String role = (String) session.getAttribute("role");
    if (studentName == null || !"student".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "browse-teachers");

    String teacherName = request.getParameter("teacher");
    if (teacherName == null || teacherName.trim().isEmpty()) {
        response.sendRedirect("browse-teachers.jsp");
        return;
    }

    String bio = "No bio written yet.";
    String qualifications = "Expert Instructor";
    String skills = "General Skills";
    int experience = 0;
    String languages = "English";
    String email = "N/A";
    String phone = "N/A";
    String photo = "";
    String social = "#";
    double ratingAvg = 0.0;
    int reviewsCount = 0;
    int followersCount = 0;
    String joinDate = "N/A";

    Connection conn = null;
    boolean isFollowing = false;
    boolean hasChatAccess = false;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch profile
        String sql = "SELECT * FROM teacher_profiles WHERE teacher_name = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, teacherName);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            bio = rs.getString("bio");
            qualifications = rs.getString("qualifications");
            skills = rs.getString("skills_expertise");
            experience = rs.getInt("experience_years");
            languages = rs.getString("languages");
            email = rs.getString("contact_email");
            phone = rs.getString("phone");
            photo = rs.getString("photo_path");
            social = rs.getString("social_links");
            ratingAvg = rs.getDouble("rating_avg");
            reviewsCount = rs.getInt("reviews_count");
            followersCount = rs.getInt("followers_count");
            Timestamp ts = rs.getTimestamp("created_at");
            if (ts != null) joinDate = ts.toString().split(" ")[0];
        }
        rs.close();
        ps.close();

        // Check if student follows this teacher
        String folSql = "SELECT COUNT(*) FROM teacher_followers WHERE student_name = ? AND teacher_name = ?";
        PreparedStatement folPs = conn.prepareStatement(folSql);
        folPs.setString(1, studentName);
        folPs.setString(2, teacherName);
        ResultSet folRs = folPs.executeQuery();
        if (folRs.next()) {
            isFollowing = (folRs.getInt(1) > 0);
        }
        folRs.close();
        folPs.close();

        // Check if student has chat access (subscribed to at least one course OR purchased at least one product)
        String accSql = "SELECT COUNT(*) FROM subscriptions WHERE student_name = ? AND teacher_name = ? AND access_status = 'Active'";
        PreparedStatement accPs = conn.prepareStatement(accSql);
        accPs.setString(1, studentName);
        accPs.setString(2, teacherName);
        ResultSet accRs = accPs.executeQuery();
        if (accRs.next()) {
            hasChatAccess = (accRs.getInt(1) > 0);
        }
        accRs.close();
        accPs.close();

        if (!hasChatAccess) {
            String prodSql = "SELECT COUNT(*) FROM payments WHERE student_name = ? AND teacher_name = ? AND payment_status = 'Paid' AND payment_type = 'Product'";
            PreparedStatement prodPs = conn.prepareStatement(prodSql);
            prodPs.setString(1, studentName);
            prodPs.setString(2, teacherName);
            ResultSet prodRs = prodPs.executeQuery();
            if (prodRs.next()) {
                hasChatAccess = (prodRs.getInt(1) > 0);
            }
            prodRs.close();
            prodPs.close();
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= teacherName %> - Profile</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
    
    <style>
        .profile-banner {
            height: 180px;
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue));
            border-radius: 20px 20px 0 0;
        }

        .profile-header-card {
            margin-top: -80px;
            background-color: var(--white);
            border-radius: 0 0 20px 20px;
            padding: 30px;
            box-shadow: var(--card-shadow);
        }

        .profile-nav-tabs .nav-link {
            border: none;
            font-weight: 600;
            color: var(--text-muted);
            padding: 15px 25px;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }

        .profile-nav-tabs .nav-link.active {
            color: var(--primary-blue);
            border-bottom-color: var(--primary-blue);
            background-color: transparent;
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            
            <div class="profile-banner"></div>
            
            <div class="profile-header-card mb-5">
                <div class="row align-items-center g-4">
                    <div class="col-md-auto text-center">
                        <div class="user-avatar text-white mx-auto shadow" style="width: 110px; height: 110px; background-color: var(--accent-blue); font-size: 3rem;">
                            <i class="bi bi-person-workspace"></i>
                        </div>
                    </div>
                    <div class="col-md text-center text-md-start">
                        <h3 class="fw-bold mb-1"><%= teacherName %></h3>
                        <p class="text-muted mb-2"><i class="bi bi-mortarboard-fill text-primary"></i> <%= qualifications %></p>
                        
                        <div class="d-flex flex-wrap justify-content-center justify-content-md-start align-items-center gap-3">
                            <span class="badge bg-light text-dark border"><i class="bi bi-calendar3 me-1"></i> Joined <%= joinDate %></span>
                            <span class="badge bg-light text-dark border"><i class="bi bi-star-fill text-warning me-1"></i> <%= String.format("%.1f", ratingAvg) %> Rating</span>
                            <span class="badge bg-light text-dark border"><i class="bi bi-people-fill text-info me-1"></i> <%= followersCount %> Followers</span>
                        </div>
                    </div>
                    <div class="col-md-auto d-flex justify-content-center gap-2">
                        <a href="../../FollowTeacherServlet?teacher=<%= java.net.URLEncoder.encode(teacherName, "UTF-8") %>" class="btn rounded-pill px-4 <%= isFollowing ? "btn-outline-secondary" : "btn-custom-primary" %>">
                            <i class="bi <%= isFollowing ? "bi-person-check-fill" : "bi-person-plus-fill" %> me-1"></i>
                            <%= isFollowing ? "Following" : "Follow Teacher" %>
                        </a>
                        
                        <% if (hasChatAccess) { %>
                            <a href="messages.jsp?chat=<%= java.net.URLEncoder.encode(teacherName, "UTF-8") %>" class="btn btn-outline-primary rounded-pill px-4">
                                <i class="bi bi-chat-fill me-1"></i> Message Teacher
                            </a>
                        <% } else { %>
                            <button class="btn btn-outline-secondary rounded-pill px-4" disabled data-bs-toggle="tooltip" title="Subscribe to their course or buy a product to start messaging.">
                                <i class="bi bi-chat-fill me-1"></i> Subscribe to Message
                            </button>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Content Tabs -->
            <ul class="nav nav-tabs profile-nav-tabs border-bottom mb-4" id="profileTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="info-tab" data-bs-toggle="tab" data-bs-target="#info-panel" type="button" role="tab">About Teacher</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="classes-tab" data-bs-toggle="tab" data-bs-target="#classes-panel" type="button" role="tab">Classes</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="products-tab" data-bs-toggle="tab" data-bs-target="#products-panel" type="button" role="tab">Products</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="videos-tab" data-bs-toggle="tab" data-bs-target="#videos-panel" type="button" role="tab">Videos</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews-panel" type="button" role="tab">Reviews (<%= reviewsCount %>)</button>
                </li>
            </ul>

            <div class="tab-content" id="profileTabsContent">
                <!-- Tab: About -->
                <div class="tab-pane fade show active" id="info-panel" role="tabpanel">
                    <div class="row g-4">
                        <div class="col-lg-8">
                            <div class="content-card">
                                <h5 class="fw-bold mb-3">Professional Bio</h5>
                                <p class="text-muted" style="line-height: 1.6;"><%= bio %></p>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="content-card">
                                <h5 class="fw-bold mb-4">Credentials & Information</h5>
                                <div class="mb-3">
                                    <span class="text-muted d-block small">EXPERTISE</span>
                                    <span class="fw-medium text-dark"><%= skills %></span>
                                </div>
                                <div class="mb-3">
                                    <span class="text-muted d-block small">YEARS OF EXPERIENCE</span>
                                    <span class="fw-medium text-dark"><%= experience %> Years</span>
                                </div>
                                <div class="mb-3">
                                    <span class="text-muted d-block small">LANGUAGES</span>
                                    <span class="fw-medium text-dark"><%= languages %></span>
                                </div>
                                <div class="mb-3">
                                    <span class="text-muted d-block small">CONTACT EMAIL</span>
                                    <span class="fw-medium text-dark"><%= email %></span>
                                </div>
                                <div class="mb-3">
                                    <span class="text-muted d-block small">SOCIAL LINK</span>
                                    <a href="<%= social %>" target="_blank" class="fw-medium text-primary"><i class="bi bi-linkedin me-1"></i> LinkedIn Profile</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab: Classes -->
                <div class="tab-pane fade" id="classes-panel" role="tabpanel">
                    <div class="row g-4">
                        <%
                            try {
                                String clSql = "SELECT * FROM skills WHERE teacher_name = ? ORDER BY skill_id DESC";
                                PreparedStatement clPs = conn.prepareStatement(clSql);
                                clPs.setString(1, teacherName);
                                ResultSet clRs = clPs.executeQuery();
                                
                                boolean hasSkills = false;
                                while (clRs.next()) {
                                    hasSkills = true;
                                    int id = clRs.getInt("skill_id");
                                    String title = clRs.getString("skill_title");
                                    String cat = clRs.getString("category");
                                    String price = clRs.getString("price");
                                    String desc = clRs.getString("description");
                        %>
                        <div class="col-md-6 col-lg-4">
                            <div class="card h-100 border-0 rounded-4 shadow-sm">
                                <div class="card-body p-4 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="badge bg-primary-tint text-primary mb-2"><%= cat %></span>
                                        <h5 class="fw-bold mb-2"><%= title %></h5>
                                        <p class="small text-muted text-truncate-3 mb-4"><%= desc %></p>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                        <h5 class="fw-bold text-success mb-0">₹<%= price %>/mo</h5>
                                        <a href="checkout.jsp?item_type=skill&item_id=<%= id %>" class="btn btn-custom-sm btn-custom-primary rounded-pill"><i class="bi bi-bookmark-plus-fill me-1"></i> Subscribe</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                                clRs.close();
                                clPs.close();
                                if (!hasSkills) {
                        %>
                        <div class="col-12 text-center text-muted py-5">No classes offered yet by this teacher.</div>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>
                </div>

                <!-- Tab: Products -->
                <div class="tab-pane fade" id="products-panel" role="tabpanel">
                    <div class="row g-4">
                        <%
                            try {
                                String prSql = "SELECT * FROM products WHERE teacher_name = ? ORDER BY product_id DESC";
                                PreparedStatement prPs = conn.prepareStatement(prSql);
                                prPs.setString(1, teacherName);
                                ResultSet prRs = prPs.executeQuery();
                                
                                boolean hasProducts = false;
                                while (prRs.next()) {
                                    hasProducts = true;
                                    int id = prRs.getInt("product_id");
                                    String name = prRs.getString("product_name");
                                    String desc = prRs.getString("description");
                                    String pType = prRs.getString("product_type");
                                    String price = prRs.getString("price");
                        %>
                        <div class="col-md-6 col-lg-4">
                            <div class="card h-100 border-0 rounded-4 shadow-sm">
                                <div class="card-body p-4 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="badge bg-success-tint text-success mb-2"><%= pType %></span>
                                        <h5 class="fw-bold mb-2"><%= name %></h5>
                                        <p class="small text-muted text-truncate-3 mb-4"><%= desc %></p>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                        <h5 class="fw-bold text-primary mb-0">₹<%= price %></h5>
                                        <a href="checkout.jsp?item_type=product&item_id=<%= id %>" class="btn btn-custom-sm btn-custom-success rounded-pill"><i class="bi bi-cart-fill me-1"></i> Buy Now</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                                prRs.close();
                                prPs.close();
                                if (!hasProducts) {
                        %>
                        <div class="col-12 text-center text-muted py-5">No products uploaded yet.</div>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>
                </div>

                <!-- Tab: Videos -->
                <div class="tab-pane fade" id="videos-panel" role="tabpanel">
                    <div class="d-flex flex-column gap-4">
                        <%
                            try {
                                // Find all distinct courses (skills) for which this teacher has uploaded videos
                                String courseSql = "SELECT DISTINCT course_name FROM videos WHERE teacher_name = ? ORDER BY course_name ASC";
                                PreparedStatement coursePs = conn.prepareStatement(courseSql);
                                coursePs.setString(1, teacherName);
                                ResultSet courseRs = coursePs.executeQuery();
                                
                                boolean hasVideos = false;
                                while (courseRs.next()) {
                                    hasVideos = true;
                                    String playlistCourse = courseRs.getString("course_name");
                        %>
                        <div class="playlist-section">
                            <div class="d-flex align-items-center gap-2 mb-3 border-bottom pb-2">
                                <div class="p-2 bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center" style="width: 38px; height: 38px;">
                                    <i class="bi bi-collection-play-fill"></i>
                                </div>
                                <h5 class="fw-bold mb-0 text-dark">Course Playlist: <%= playlistCourse %></h5>
                            </div>
                            
                            <div class="row g-4">
                                <%
                                    String vSql = "SELECT * FROM videos WHERE teacher_name = ? AND course_name = ? ORDER BY video_id ASC";
                                    PreparedStatement vPs = conn.prepareStatement(vSql);
                                    vPs.setString(1, teacherName);
                                    vPs.setString(2, playlistCourse);
                                    ResultSet vRs = vPs.executeQuery();
                                    
                                    while (vRs.next()) {
                                        int id = vRs.getInt("video_id");
                                        String title = vRs.getString("video_title");
                                        String desc = vRs.getString("description");
                                        String preview = vRs.getString("preview_enabled");
                                        String duration = vRs.getString("duration");
                                        String thumb = vRs.getString("thumbnail_path");
                                        
                                        // Check if student has subscription access to watch
                                        boolean hasAccess = "Yes".equalsIgnoreCase(preview);
                                        if (!hasAccess) {
                                            String subSql = "SELECT COUNT(*) FROM subscriptions WHERE student_name = ? AND course_name = ? AND teacher_name = ? AND access_status = 'Active'";
                                            PreparedStatement subPs = conn.prepareStatement(subSql);
                                            subPs.setString(1, studentName);
                                            subPs.setString(2, playlistCourse);
                                            subPs.setString(3, teacherName);
                                            ResultSet subRs = subPs.executeQuery();
                                            if (subRs.next()) {
                                                hasAccess = (subRs.getInt(1) > 0);
                                            }
                                            subRs.close();
                                            subPs.close();
                                        }
                                %>
                                <div class="col-md-6 col-lg-4">
                                    <div class="card h-100 border-0 rounded-4 shadow-sm overflow-hidden">
                                        <div class="ratio ratio-16x9 bg-light d-flex align-items-center justify-content-center border-bottom text-muted position-relative">
                                            <% if (thumb != null && !thumb.isEmpty() && !"default_thumb.jpg".equals(thumb)) { %>
                                                <img src="../../<%= thumb %>" alt="thumbnail" style="width: 100%; height: 100%; object-fit: cover;">
                                            <% } else { %>
                                                <div class="d-flex flex-column align-items-center justify-content-center h-100 w-100">
                                                    <i class="bi bi-play-circle-fill fs-1 text-primary"></i>
                                                    <span class="small mt-2"><%= duration %> Duration</span>
                                                </div>
                                            <% } %>
                                            <% if (!hasAccess) { %>
                                                <div class="position-absolute top-0 end-0 m-2 badge bg-danger"><i class="bi bi-lock-fill"></i> Premium</div>
                                            <% } else if ("Yes".equalsIgnoreCase(preview)) { %>
                                                <div class="position-absolute top-0 end-0 m-2 badge bg-success"><i class="bi bi-unlock-fill"></i> Preview</div>
                                            <% } %>
                                        </div>
                                        <div class="card-body p-4 d-flex flex-column justify-content-between">
                                            <div>
                                                <h5 class="fw-bold mb-1"><%= title %></h5>
                                                <span class="small text-muted d-block mb-3">Course: <%= playlistCourse %></span>
                                                <p class="small text-muted text-truncate-2 mb-4"><%= desc %></p>
                                            </div>
                                            <div class="mt-2 text-end">
                                                <% if (hasAccess) { %>
                                                    <a href="watch-video.jsp?id=<%= id %>" class="btn btn-custom-sm btn-primary rounded-pill w-100"><i class="bi bi-play-fill"></i> Watch Now</a>
                                                <% } else { %>
                                                    <div class="p-2 border rounded-4 bg-light text-center small text-danger"><i class="bi bi-lock-fill"></i> Subscription required.</div>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <%
                                    }
                                    vRs.close();
                                    vPs.close();
                                %>
                            </div>
                        </div>
                        <%
                                }
                                courseRs.close();
                                coursePs.close();
                                
                                if (!hasVideos) {
                        %>
                        <div class="content-card text-center text-muted py-5">
                            <i class="bi bi-collection-play fs-1 mb-2 d-block"></i>
                            No educational class playlists uploaded by this teacher.
                        </div>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>
                </div>

                <!-- Tab: Reviews -->
                <div class="tab-pane fade" id="reviews-panel" role="tabpanel">
                    <div class="row g-4">
                        <div class="col-lg-5">
                            <!-- Leave a Review Form -->
                            <div class="content-card">
                                <h5 class="fw-bold mb-4">Leave a Review</h5>
                                <form action="../../AddReviewServlet" method="post">
                                    <input type="hidden" name="teacher" value="<%= teacherName %>">
                                    <div class="mb-3">
                                        <label for="rating" class="form-label fw-semibold small">Rating Stars</label>
                                        <select id="rating" name="rating" class="form-select" required>
                                            <option value="5">★★★★★ (5 Stars)</option>
                                            <option value="4">★★★★☆ (4 Stars)</option>
                                            <option value="3">★★★☆☆ (3 Stars)</option>
                                            <option value="2">★★☆☆☆ (2 Stars)</option>
                                            <option value="1">★☆☆☆☆ (1 Star)</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label for="review" class="form-label fw-semibold small">Your Feedback</label>
                                        <textarea id="review" name="review" class="form-control" rows="4" placeholder="What was your experience learning with this teacher?" required></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill w-100"><i class="bi bi-chat-text-fill me-1"></i> Submit Feedback</button>
                                </form>
                            </div>
                        </div>

                        <div class="col-lg-7">
                            <div class="content-card">
                                <h5 class="fw-bold mb-4">Student Feedback</h5>
                                <div class="d-flex flex-column gap-3">
                                    <%
                                        try {
                                            String revSql = "SELECT * FROM reviews WHERE teacher_name = ? ORDER BY review_id DESC";
                                            PreparedStatement revPs = conn.prepareStatement(revSql);
                                            revPs.setString(1, teacherName);
                                            ResultSet revRs = revPs.executeQuery();
                                            
                                            boolean hasReviews = false;
                                            while (revRs.next()) {
                                                hasReviews = true;
                                                String sName = revRs.getString("student_name");
                                                int rating = revRs.getInt("rating");
                                                String text = revRs.getString("review_text");
                                                Timestamp t = revRs.getTimestamp("created_at");
                                                String dateStr = t != null ? t.toString().split(" ")[0] : "N/A";
                                                
                                                String stars = "";
                                                for (int i=0; i<5; i++) {
                                                    if (i<rating) stars += "★";
                                                    else stars += "☆";
                                                }
                                    %>
                                    <div class="p-3 border rounded-4">
                                        <div class="d-flex justify-content-between mb-2">
                                            <span class="fw-bold text-dark"><%= sName %></span>
                                            <span class="small text-muted"><%= dateStr %></span>
                                        </div>
                                        <div class="text-warning mb-2"><%= stars %></div>
                                        <p class="text-muted small mb-0"><%= text %></p>
                                    </div>
                                    <%
                                            }
                                            revRs.close();
                                            revPs.close();
                                            if (!hasReviews) {
                                    %>
                                    <div class="text-center text-muted small py-4">No student reviews written yet.</div>
                                    <%
                                            }
                                        } catch(Exception e) {
                                            e.printStackTrace();
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Enable Tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        })
    </script>
</body>
</html>
<%
    if (conn != null) {
        try { conn.close(); } catch(Exception e) {}
    }
%>
