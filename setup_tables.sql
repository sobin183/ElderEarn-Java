CREATE DATABASE IF NOT EXISTS elderearn;
USE elderearn;

CREATE TABLE IF NOT EXISTS teacher_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL UNIQUE,
    bio TEXT,
    qualifications VARCHAR(255),
    skills_expertise VARCHAR(255),
    experience_years INT DEFAULT 0,
    languages VARCHAR(255),
    contact_email VARCHAR(100),
    phone VARCHAR(50),
    photo_path VARCHAR(255),
    social_links VARCHAR(255),
    rating_avg DECIMAL(3,2) DEFAULT 0.00,
    reviews_count INT DEFAULT 0,
    followers_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS videos (
    video_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    video_title VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    duration VARCHAR(50),
    thumbnail_path VARCHAR(255),
    video_path VARCHAR(255),
    preview_enabled VARCHAR(10) DEFAULT 'No',
    views_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_name VARCHAR(100) NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    message_text TEXT NOT NULL,
    is_read INT DEFAULT 0,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    message_text TEXT NOT NULL,
    is_read INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS teacher_followers (
    follower_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    teacher_name VARCHAR(100) NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_follow (student_name, teacher_name)
);

CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    rating INT NOT NULL,
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
