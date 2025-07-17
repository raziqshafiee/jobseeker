-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 13, 2025 at 07:24 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Database: `jobseeker`
CREATE DATABASE IF NOT EXISTS `jobseeker` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `jobseeker`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEmployerDashboard` (IN `employer_id` INT)   BEGIN
    -- Employer's jobs summary
    SELECT 
        COUNT(*) as total_jobs_posted,
        COUNT(CASE WHEN j.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as jobs_this_month
    FROM jobs j
    WHERE j.posted_by = employer_id;
    
    -- Applications received summary
    SELECT 
        COUNT(*) as total_applications,
        COUNT(CASE WHEN a.status = 'pending' THEN 1 END) as pending,
        COUNT(CASE WHEN a.status = 'reviewed' THEN 1 END) as reviewed,
        COUNT(CASE WHEN a.status = 'accepted' THEN 1 END) as accepted,
        COUNT(CASE WHEN a.status = 'rejected' THEN 1 END) as rejected
    FROM applications a
    JOIN jobs j ON a.job_id = j.id
    WHERE j.posted_by = employer_id;
    
    -- Recent applications received
    SELECT 
        a.id,
        a.status,
        a.created_at,
        u.first_name,
        u.last_name,
        u.email,
        j.title
    FROM applications a
    JOIN jobs j ON a.job_id = j.id
    JOIN users u ON a.user_id = u.id
    WHERE j.posted_by = employer_id
    ORDER BY a.created_at DESC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserDashboard` (IN `user_id` INT)   BEGIN
    -- User's application summary
    SELECT 
        COUNT(*) as total_applications,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
        COUNT(CASE WHEN status = 'reviewed' THEN 1 END) as reviewed,
        COUNT(CASE WHEN status = 'accepted' THEN 1 END) as accepted,
        COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected
    FROM applications 
    WHERE user_id = user_id;
    
    -- User's saved jobs count
    SELECT COUNT(*) as saved_jobs_count 
    FROM saved_jobs 
    WHERE user_id = user_id;
    
    -- Recent applications
    SELECT 
        a.id,
        a.status,
        a.created_at,
        j.title,
        j.company,
        j.location
    FROM applications a
    JOIN jobs j ON a.job_id = j.id
    WHERE a.user_id = user_id
    ORDER BY a.created_at DESC
    LIMIT 5;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `applications`
--
CREATE TABLE `applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` enum('pending','reviewed','accepted','rejected') DEFAULT 'pending',
  `cover_letter` text DEFAULT NULL,
  `requires_assessment` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_application` (`job_id`,`user_id`),
  KEY `idx_job_id` (`job_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_applications_status_created` (`status`,`created_at`),
  KEY `idx_requires_assessment` (`requires_assessment`),
  KEY `idx_applications_user_job` (`user_id`,`job_id`),
  KEY `idx_applications_status` (`status`),
  CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--
CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `company` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `requirements` text DEFAULT NULL,
  `salary_range` varchar(100) DEFAULT NULL,
  `posted_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` enum('active','inactive','filled') DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `idx_title` (`title`),
  KEY `idx_company` (`company`),
  KEY `idx_location` (`location`),
  KEY `idx_type` (`type`),
  KEY `idx_posted_by` (`posted_by`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_jobs_type_location` (`type`,`location`),
  KEY `idx_jobs_company_created` (`company`,`created_at`),
  KEY `idx_jobs_posted_by` (`posted_by`),
  KEY `idx_jobs_status` (`status`),
  FULLTEXT KEY `idx_search_content` (`title`,`company`,`location`,`description`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `saved_jobs`
--
CREATE TABLE `saved_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_saved_job` (`job_id`,`user_id`),
  KEY `idx_job_id` (`job_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `saved_jobs_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `saved_jobs_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firebase_uid` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `role` enum('job_seeker','employer','admin') DEFAULT 'job_seeker',
  `phone` varchar(20) DEFAULT NULL,
  `assessment_score` decimal(5,2) DEFAULT NULL,
  `assessment_completed` tinyint(1) DEFAULT 0,
  `assessment_date` timestamp NULL DEFAULT NULL,
  `resume_url` varchar(500) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `profile_picture` varchar(500) DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `firebase_uid` (`firebase_uid`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_users_role_created` (`role`,`created_at`),
  KEY `idx_assessment_score` (`assessment_score`),
  KEY `idx_assessment_completed` (`assessment_completed`),
  KEY `idx_users_assessment_combo` (`assessment_completed`,`assessment_score`),
  KEY `idx_firebase_uid` (`firebase_uid`),
  KEY `idx_users_role` (`role`),
 money_key `idx_users_assessment` (`assessment_completed`,`assessment_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_assessments`
--
CREATE TABLE `user_assessments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `total_questions` int(11) NOT NULL DEFAULT 15,
  `correct_answers` int(11) NOT NULL,
  `total_points` int(11) NOT NULL,
  `max_possible_points` int(11) NOT NULL DEFAULT 150,
  `percentage_score` decimal(5,2) NOT NULL,
  `time_taken_seconds` int(11) DEFAULT NULL,
  `skill_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`skill_scores`)),
  `user_answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`user_answers`)),
  `completed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_assessment` (`user_id`),
  KEY `idx_percentage_score` (`percentage_score`),
  KEY `idx_assessments_score_desc` (`percentage_score`),
  CONSTRAINT `user_assessments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `user_assessments`
--
DELIMITER $$
CREATE TRIGGER `update_user_assessment_info` AFTER INSERT ON `user_assessments` FOR EACH ROW BEGIN
    UPDATE `users` 
    SET 
        `assessment_score` = NEW.percentage_score,
        `assessment_completed` = 1,
        `assessment_date` = NEW.completed_at
    WHERE `id` = NEW.user_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure for view `jobs_with_stats`
--
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `jobs_with_stats` AS 
SELECT 
    `j`.`id` AS `id`, 
    `j`.`title` AS `title`, 
    `j`.`company` AS `company`, 
    `j`.`location` AS `location`, 
    `j`.`type` AS `type`, 
    `j`.`description` AS `description`, 
    `j`.`requirements` AS `requirements`, 
    `j`.`salary_range` AS `salary_range`, 
    `j`.`posted_by` AS `posted_by`, 
    `j`.`created_at` AS `created_at`, 
    `j`.`updated_at` AS `updated_at`, 
    concat(`u`.`first_name`, ' ', `u`.`last_name`) AS `posted_by_name`, 
    `u`.`company_name` AS `posted_by_company`, 
    count(`a`.`id`) AS `application_count`, 
    count(case when `a`.`status` = 'pending' then 1 end) AS `pending_applications`, 
    count(case when `a`.`status` = 'reviewed' then 1 end) AS `reviewed_applications`, 
    count(case when `a`.`status` = 'accepted' then 1 end) AS `accepted_applications`, 
    count(case when `a`.`status` = 'rejected' then 1 end) AS `rejected_applications` 
FROM 
    ((`jobs` `j` 
    left join `users` `u` on(`j`.`posted_by` = `u`.`id`)) 
    left join `applications` `a` on(`j`.`id` = `a`.`job_id`)) 
GROUP BY 
    `j`.`id` 
ORDER BY 
    `j`.`created_at` DESC;

-- --------------------------------------------------------

--
-- Structure for view `job_applications_view`
--
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `job_applications_view` AS 
SELECT 
    `a`.`id` AS `application_id`, 
    `a`.`status` AS `status`, 
    `a`.`created_at` AS `applied_date`, 
    `a`.`cover_letter` AS `cover_letter`, 
    `u`.`first_name` AS `first_name`, 
    `u`.`last_name` AS `last_name`, 
    `u`.`email` AS `email`, 
    `u`.`phone` AS `phone`, 
    `j`.`id` AS `job_id`, 
    `j`.`title` AS `title`, 
    `j`.`company` AS `company`, 
    `j`.`location` AS `location`, 
    `j`.`type` AS `type`, 
    `j`.`salary_range` AS `salary_range` 
FROM 
    ((`applications` `a` 
    join `users` `u` on(`a`.`user_id` = `u`.`id`)) 
    join `jobs` `j` on(`a`.`job_id` = `j`.`id`)) 
ORDER BY 
    `a`.`created_at` DESC;

-- --------------------------------------------------------

--
-- Structure for view `job_seeker_profiles`
--
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `job_seeker_profiles` AS 
SELECT 
    `u`.`id` AS `id`, 
    `u`.`first_name` AS `first_name`, 
    `u`.`last_name` AS `last_name`, 
    `u`.`email` AS `email`, 
    `u`.`phone` AS `phone`, 
    `u`.`assessment_score` AS `assessment_score`, 
    `u`.`assessment_completed` AS `assessment_completed`, 
    `u`.`assessment_date` AS `assessment_date`, 
    `u`.`created_at` AS `member_since`, 
    CASE 
        WHEN `u`.`assessment_score` >= 90 THEN 'Excellent' 
        WHEN `u`.`assessment_score` >= 80 THEN 'Very Good' 
        WHEN `u`.`assessment_score` >= 70 THEN 'Good' 
        WHEN `u`.`assessment_score` >= 60 THEN 'Satisfactory' 
        WHEN `u`.`assessment_score` < 60 THEN 'Needs Improvement' 
        ELSE 'Not Assessed' 
    END AS `assessment_level` 
FROM 
    `users` AS `u` 
WHERE 
    `u`.`role` = 'job_seeker';

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;