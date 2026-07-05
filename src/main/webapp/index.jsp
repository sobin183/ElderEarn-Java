<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ElderEarn – Skill Sharing and Micro-Earning Platform</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-blue: #0f4c81;
            --accent-blue: #3a86c8;
            --sky-blue: #e8f4fd;
            --deep-dark: #0b1a30;
            --body-bg: #f8fafc;
            --white: #ffffff;
            --text-muted: #64748b;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--body-bg);
            color: var(--deep-dark);
            overflow-x: hidden;
        }

        /* Navbar Customization */
        .navbar {
            background-color: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(15, 76, 129, 0.08);
            transition: all 0.3s ease;
        }

        .navbar-brand {
            font-weight: 800;
            color: var(--primary-blue) !important;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .nav-link {
            font-weight: 500;
            color: var(--deep-dark) !important;
            padding: 8px 16px !important;
            transition: color 0.3s;
        }

        .nav-link:hover {
            color: var(--accent-blue) !important;
        }

        /* Hero Section */
        .hero-section {
            background: linear-gradient(135deg, #ffffff 30%, var(--sky-blue) 100%);
            padding: 160px 0 100px 0;
            position: relative;
        }

        .hero-title {
            font-weight: 800;
            font-size: 3.5rem;
            line-height: 1.2;
            color: var(--deep-dark);
        }

        .hero-title span {
            color: var(--primary-blue);
        }

        .hero-lead {
            font-size: 1.25rem;
            color: var(--text-muted);
            margin-bottom: 2rem;
        }

        .btn-custom-primary {
            background-color: var(--primary-blue);
            color: var(--white);
            font-weight: 600;
            padding: 12px 30px;
            border-radius: 50px;
            border: 2px solid var(--primary-blue);
            transition: all 0.3s;
        }

        .btn-custom-primary:hover {
            background-color: transparent;
            color: var(--primary-blue);
            transform: translateY(-2px);
        }

        .btn-custom-secondary {
            background-color: transparent;
            color: var(--primary-blue);
            font-weight: 600;
            padding: 12px 30px;
            border-radius: 50px;
            border: 2px solid var(--primary-blue);
            transition: all 0.3s;
        }

        .btn-custom-secondary:hover {
            background-color: var(--primary-blue);
            color: var(--white);
            transform: translateY(-2px);
        }

        /* Section Styling */
        .section-padding {
            padding: 90px 0;
        }

        .section-header {
            margin-bottom: 60px;
            text-align: center;
        }

        .section-header h2 {
            font-weight: 800;
            font-size: 2.5rem;
            color: var(--primary-blue);
            position: relative;
            display: inline-block;
            padding-bottom: 15px;
        }

        .section-header h2::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 4px;
            background-color: var(--accent-blue);
            border-radius: 2px;
        }

        /* Feature Cards */
        .feature-card {
            background-color: var(--white);
            border: none;
            border-radius: 20px;
            padding: 40px 30px;
            box-shadow: 0 10px 30px rgba(15, 76, 129, 0.05);
            transition: all 0.3s;
            height: 100%;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(15, 76, 129, 0.1);
        }

        .feature-icon-wrapper {
            width: 70px;
            height: 70px;
            border-radius: 50px;
            background-color: var(--sky-blue);
            color: var(--primary-blue);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 25px;
        }

        /* SDG Cards */
        .sdg-card {
            border: none;
            border-radius: 20px;
            color: var(--white);
            overflow: hidden;
            position: relative;
            height: 100%;
            transition: transform 0.3s;
        }

        .sdg-card:hover {
            transform: scale(1.03);
        }

        .sdg-1 { background-color: #e5243b; }
        .sdg-4 { background-color: #c5192d; }
        .sdg-8 { background-color: #a21942; }
        .sdg-10 { background-color: #dd1367; }

        .sdg-card-body {
            padding: 35px 30px;
        }

        .sdg-number {
            font-size: 3.5rem;
            font-weight: 800;
            opacity: 0.25;
            position: absolute;
            right: 20px;
            top: 10px;
        }

        /* Contact Section */
        .contact-box {
            background-color: var(--white);
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(15, 76, 129, 0.06);
            overflow: hidden;
        }

        .contact-info-panel {
            background-color: var(--primary-blue);
            color: var(--white);
            padding: 50px;
            height: 100%;
        }

        .contact-form-panel {
            padding: 50px;
        }

        .form-control {
            border-radius: 10px;
            padding: 12px 18px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }

        .form-control:focus {
            border-color: var(--primary-blue);
            box-shadow: 0 0 0 4px rgba(15, 76, 129, 0.1);
        }

        /* Footer */
        footer {
            background-color: var(--deep-dark);
            color: rgba(255, 255, 255, 0.7);
            padding: 60px 0 30px 0;
        }

        footer h5 {
            color: var(--white);
            font-weight: 700;
            margin-bottom: 25px;
        }

        footer a {
            color: rgba(255, 255, 255, 0.6);
            text-decoration: none;
            transition: color 0.3s;
        }

        footer a:hover {
            color: var(--white);
        }
    </style>
</head>
<body>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-light fixed-top shadow-sm">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="bi bi-mortarboard-fill"></i> ElderEarn
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item"><a class="nav-link" href="#home">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="#about">About</a></li>
                    <li class="nav-item"><a class="nav-link" href="#features">Features</a></li>
                    <li class="nav-item"><a class="nav-link" href="#sdgs">SDGs</a></li>
                    <li class="nav-item"><a class="nav-link" href="#contact">Contact</a></li>
                    <li class="nav-item ms-lg-3 mt-2 mt-lg-0">
                        <a href="jsp/auth/login.jsp" class="btn btn-outline-primary rounded-pill px-4">Login</a>
                    </li>
                    <li class="nav-item ms-lg-2 mt-2 mt-lg-0">
                        <a href="jsp/auth/register.jsp" class="btn btn-primary rounded-pill px-4">Register</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section id="home" class="hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <h1 class="hero-title mb-4">Empowering <span>Elders</span>, Educating the <span>Future</span>.</h1>
                    <p class="hero-lead">ElderEarn connects experienced retirees and experts with learners worldwide. Share your lifelong knowledge, upload educational resources, create micro-earnings, and build a brighter community.</p>
                    <div class="d-flex gap-3">
                        <a href="jsp/auth/register.jsp?role=teacher" class="btn btn-custom-primary">Teach & Earn</a>
                        <a href="jsp/auth/register.jsp?role=student" class="btn btn-custom-secondary">Browse Skills</a>
                    </div>
                </div>
                <div class="col-lg-6 text-center mt-5 mt-lg-0">
                    <img src="https://img.freepik.com/free-vector/old-young-people-communicating-vector-flat-illustration-grandmother-grandfather-talking-with-grandchildren-together-family-sitting-sofa-smiling-isolated-white_107791-10515.jpg" alt="Lifelong Learning" class="img-fluid rounded-4 shadow" style="max-height: 400px; object-fit: cover;">
                </div>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section id="about" class="section-padding">
        <div class="container">
            <div class="section-header">
                <h2>About ElderEarn</h2>
                <p class="lead text-muted max-width-600 mx-auto mt-2">Bridging generational gaps through structured education, digital marketplace assets, and mentorship.</p>
            </div>
            <div class="row align-items-center">
                <div class="col-lg-5 text-center mb-5 mb-lg-0">
                    <div class="p-4 bg-white shadow rounded-4">
                        <i class="bi bi-quote fs-1 text-primary"></i>
                        <p class="fst-italic fs-5">"ElderEarn gave me a renewed sense of purpose. I retired as a language professor, and now I teach young professionals globally and earn an extra income."</p>
                        <h6 class="fw-bold mt-3 mb-0">— Prof. Arthur Miller, 72 (ElderEarn Teacher)</h6>
                    </div>
                </div>
                <div class="col-lg-7 ps-lg-5">
                    <h3 class="fw-bold mb-3">Our Mission</h3>
                    <p>ElderEarn was created to address two critical modern issues: the isolation and lack of structured earning opportunities for senior citizens, and the rising demand for authentic, affordable, and practical education. We provide a space where seasoned experts can host skills, teach lessons via subscriptions, and sell digitized notes, craftworks, or digital files in our student marketplace.</p>
                    <p>Whether you're looking to learn gardening from a 40-year horticulturist, programming from a retired consultant, or cooking from a culinary grandmother, ElderEarn is the home for practical wisdom.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="section-padding bg-light">
        <div class="container">
            <div class="section-header">
                <h2>Key Features</h2>
            </div>
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon-wrapper"><i class="bi bi-easel2-fill"></i></div>
                        <h4 class="fw-bold">Skill Sharing</h4>
                        <p class="text-muted">Host live courses or video classes on diverse topics like agriculture, cookery, music, and business.</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon-wrapper"><i class="bi bi-cart4"></i></div>
                        <h4 class="fw-bold">Marketplace</h4>
                        <p class="text-muted">Sell PDFs, templates, physical crafts, textbooks, or reference notes directly to eager learners.</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon-wrapper"><i class="bi bi-wallet2"></i></div>
                        <h4 class="fw-bold">Micro-Earning</h4>
                        <p class="text-muted">Earn direct payouts from subscriptions and purchases, managed via our transparent payments dashboard.</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon-wrapper"><i class="bi bi-shield-check"></i></div>
                        <h4 class="fw-bold">Admin Controls</h4>
                        <p class="text-muted">Full administrative authorization processes ensure students gain valid, secure, and authentic access.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- SDG Section -->
    <section id="sdgs" class="section-padding">
        <div class="container">
            <div class="section-header">
                <h2>Sustainable Development Goals</h2>
                <p class="lead text-muted mt-2">How ElderEarn aligns with the United Nations Sustainable Development Goals (SDGs).</p>
            </div>
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="sdg-card sdg-1">
                        <div class="sdg-card-body">
                            <div class="sdg-number">01</div>
                            <h4 class="fw-bold"><i class="bi bi-heart-fill me-2"></i> SDG 1: No Poverty</h4>
                            <p class="small mt-3">Supplementing the livelihoods of seniors and retired professionals by enabling digital monetization of their expertise, preventing post-retirement financial hardships.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="sdg-card sdg-4">
                        <div class="sdg-card-body">
                            <div class="sdg-number">04</div>
                            <h4 class="fw-bold"><i class="bi bi-book-fill me-2"></i> SDG 4: Quality Education</h4>
                            <p class="small mt-3">Promoting lifelong learning opportunities. Eager students obtain direct access to authentic, experienced, and high-quality mentor-led classes.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="sdg-card sdg-8">
                        <div class="sdg-card-body">
                            <div class="sdg-number">08</div>
                            <h4 class="fw-bold"><i class="bi bi-briefcase-fill me-2"></i> SDG 8: Decent Work</h4>
                            <p class="small mt-3">Providing micro-earning gig options that are accessible from home, encouraging inclusive economic growth and productive employment for elderly teachers.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="sdg-card sdg-10">
                        <div class="sdg-card-body">
                            <div class="sdg-number">10</div>
                            <h4 class="fw-bold"><i class="bi bi-people-fill me-2"></i> SDG 10: Reduced Inequality</h4>
                            <p class="small mt-3">Decreasing generational inequalities by integrating seniors into the modern digital platform economy, promoting age-inclusive social and economic status.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section id="contact" class="section-padding bg-light">
        <div class="container">
            <div class="contact-box row g-0">
                <div class="col-lg-5">
                    <div class="contact-info-panel d-flex flex-column justify-content-between">
                        <div>
                            <h3 class="fw-bold mb-4">Contact Information</h3>
                            <p class="mb-4">Have questions about setting up your course or payment settings? Reach out to our 24/7 Support Team.</p>
                            <div class="d-flex align-items-center mb-3">
                                <i class="bi bi-geo-alt-fill me-3 fs-5"></i>
                                <span>100 ElderEarn Way, Silicon Valley, CA</span>
                            </div>
                            <div class="d-flex align-items-center mb-3">
                                <i class="bi bi-telephone-fill me-3 fs-5"></i>
                                <span>+1 (800) 555-EARN</span>
                            </div>
                            <div class="d-flex align-items-center mb-3">
                                <i class="bi bi-envelope-fill me-3 fs-5"></i>
                                <span>support@elderearn.com</span>
                            </div>
                        </div>
                        <div class="d-flex gap-3 fs-4 mt-5">
                            <a href="#" class="text-white"><i class="bi bi-facebook"></i></a>
                            <a href="#" class="text-white"><i class="bi bi-twitter-x"></i></a>
                            <a href="#" class="text-white"><i class="bi bi-instagram"></i></a>
                            <a href="#" class="text-white"><i class="bi bi-linkedin"></i></a>
                        </div>
                    </div>
                </div>
                <div class="col-lg-7">
                    <div class="contact-form-panel">
                        <h3 class="fw-bold mb-4">Send Us a Message</h3>
                        <form action="#">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">First Name</label>
                                    <input type="text" class="form-control" placeholder="" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Last Name</label>
                                    <input type="text" class="form-control" placeholder="" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Email Address</label>
                                    <input type="email" class="form-control" placeholder="" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Message</label>
                                    <textarea class="form-control" rows="4" placeholder="How can we help you?" required></textarea>
                                </div>
                                <div class="col-12">
                                    <button type="submit" class="btn btn-custom-primary w-100 mt-2">Submit Message</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="container text-center text-md-start">
            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <h5 class="navbar-brand text-white mb-3"><i class="bi bi-mortarboard-fill"></i> ElderEarn</h5>
                    <p class="small text-muted">A dedicated space empowering seniors to gain independence, pass on rich expertise, and earn from their legacy, whilst providing authentic skills to eager students worldwide.</p>
                </div>
                <div class="col-md-2 offset-md-1">
                    <h5>Quick Links</h5>
                    <ul class="list-unstyled">
                        <li><a href="#home">Home</a></li>
                        <li><a href="#about">About</a></li>
                        <li><a href="#features">Features</a></li>
                        <li><a href="#sdgs">SDGs</a></li>
                    </ul>
                </div>
                <div class="col-md-2">
                    <h5>Support</h5>
                    <ul class="list-unstyled">
                        <li><a href="#contact">Contact Support</a></li>
                        <li><a href="jsp/auth/login.jsp">Login Page</a></li>
                        <li><a href="jsp/auth/register.jsp">Register</a></li>
                        <li><a href="#">FAQ</a></li>
                    </ul>
                </div>
                <div class="col-md-3">
                    <h5>Newsletter</h5>
                    <p class="small text-muted">Subscribe to receive monthly course openings and teaching highlights.</p>
                    <div class="input-group">
                        <input type="email" class="form-control form-control-sm" placeholder="Your Email">
                        <button class="btn btn-primary btn-sm"><i class="bi bi-send"></i></button>
                    </div>
                </div>
            </div>
            <hr class="border-secondary">
            <div class="row align-items-center text-muted small">
                <div class="col-md-6 text-center text-md-start">
                    &copy; 2026 ElderEarn. All rights reserved.
                </div>
                <div class="col-md-6 text-center text-md-end mt-2 mt-md-0">
                    <a href="#" class="me-3">Privacy Policy</a>
                    <a href="#">Terms of Service</a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5 Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>