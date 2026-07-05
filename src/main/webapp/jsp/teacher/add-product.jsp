<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String teacherName = (String) session.getAttribute("full_name");
    String teacherRole = (String) session.getAttribute("role");
    if (teacherName == null || !"teacher".equals(teacherRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "add-product");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Product - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Add New Product</h2>
                    <p class="text-muted mb-0">Upload items like notes, textbooks, templates, digital assets, or craft pieces.</p>
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
                        <form action="../../AddProductServlet" method="post">
                            <div class="mb-4">
                                <label for="product_name" class="form-label fw-bold">Product Name</label>
                                <input type="text" id="product_name" name="product_name" class="form-control" placeholder="e.g. Advanced Chemistry Revision Guide 2026" required>
                                <div class="form-text">Choose a descriptive and clear title for your resource.</div>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label for="product_type" class="form-label fw-bold">Product Category</label>
                                    <select id="product_type" name="product_type" class="form-select" required>
                                        <option value="">Select Category</option>
                                        <option value="Books">Books</option>
                                        <option value="Notes">Notes</option>
                                        <option value="Templates">Templates</option>
                                        <option value="Craft Items">Craft Items</option>
                                        <option value="Digital Products">Digital Products</option>
                                        <option value="Courses">Courses</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="price" class="form-label fw-bold">Sale Price (One-time, ₹)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light text-muted">₹</span>
                                        <input type="number" id="price" name="price" min="0" step="1" class="form-control" placeholder="250" required>
                                    </div>
                                    <div class="form-text">Set a flat price for lifetime access or download.</div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label fw-bold">Detailed Description</label>
                                <textarea id="description" name="description" class="form-control" rows="6" placeholder="Describe what the product contains, file formats included, number of pages, or size..." required></textarea>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-custom btn-custom-primary px-4"><i class="bi bi-cloud-arrow-up-fill me-1"></i> Upload Product</button>
                                <a href="view-my-products.jsp" class="btn btn-light border px-4">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="content-card bg-success-tint border-0 text-success-emphasis">
                        <h5 class="fw-bold mb-3"><i class="bi bi-gift-fill"></i> Product Guidance</h5>
                        <ul class="list-unstyled mb-0 small">
                            <li class="mb-3 d-flex align-items-start gap-2">
                                <i class="bi bi-check-circle-fill mt-0.5"></i>
                                <span><strong>Product Types:</strong> Books and Notes are ideal for academic assistance, while Craft Items are perfect for physical/handmade goods.</span>
                            </li>
                            <li class="mb-3 d-flex align-items-start gap-2">
                                <i class="bi bi-check-circle-fill mt-0.5"></i>
                                <span><strong>Clear Description:</strong> Specify file type (e.g. PDF, DOCX, ZIP) and list table of contents or craft dimensions.</span>
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
