-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 13, 2025 at 05:38 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `jobseeker`
--

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
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` enum('pending','reviewed','accepted','rejected') DEFAULT 'pending',
  `cover_letter` text DEFAULT NULL,
  `requires_assessment` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `applications`
--

INSERT INTO `applications` (`id`, `job_id`, `user_id`, `status`, `cover_letter`, `requires_assessment`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'pending', 'I am excited to apply for the Senior Frontend Developer position at Google. With 6 years of experience in React and TypeScript, I believe I would be a great addition to your team.', 1, '2025-07-12 09:55:02', '2025-07-12 09:55:02'),
(2, 2, 1, 'reviewed', 'I am passionate about data science and would love to contribute to Meta\'s mission of connecting people through data-driven insights.', 1, '2025-07-12 09:55:02', '2025-07-12 09:55:02'),
(3, 3, 2, 'accepted', 'As a UX designer with 5 years of experience, I am thrilled about the opportunity to work on Apple\'s innovative products.', 1, '2025-07-12 09:55:02', '2025-07-12 09:55:02'),
(4, 4, 2, 'pending', 'I have extensive backend experience with Java and microservices, and I am excited about Netflix\'s technical challenges.', 1, '2025-07-12 09:55:02', '2025-07-12 09:55:02'),
(5, 5, 3, 'rejected', 'I am interested in the DevOps role at Amazon and have strong experience with AWS and containerization.', 1, '2025-07-12 09:55:02', '2025-07-12 09:55:02'),
(6, 1, 3, 'pending', 'Google has always been my dream company, and I believe my frontend skills would be valuable to your team.', 1, '2025-07-12 09:55:02', '2025-07-12 09:55:02'),
(25, 16, 11, 'reviewed', 'asa', 1, '2025-07-12 19:11:50', '2025-07-13 10:31:41'),
(26, 16, 8, 'accepted', '[Your Name]\n[Your Address]\n[City, State, Zip Code]\n[Email Address]\n[Phone Number]\n[Date]\n\n[Hiring Manager’s Name]\n[Company Name]\n[Company Address]\n[City, State, Zip Code]\n\nDear [Hiring Manager\'s Name],\n\nI am writing to express my keen interest in the Software Engineer position at [Company Name], as advertised. With a strong foundation in software development, a passion for problem-solving, and a commitment to continuous learning, I am confident in my ability to contribute meaningfully to your engineering team.\n\nDuring my academic and internship experiences, I have developed hands-on proficiency in languages and technologies such as Java, JavaScript, PHP, MySQL, and frameworks like CodeIgniter. I have worked on various real-world projects, including developing web applications, implementing RESTful APIs, and participating in user acceptance testing (UAT) to enhance system reliability and user experience.\n\nI am particularly impressed by [Company Name]’s reputation for innovation and commitment to high-quality software solutions. I am excited by the opportunity to apply my skills in a collaborative environment, where I can grow as a developer while contributing to impactful projects.\n\nI am confident that my technical background, collaborative mindset, and passion for software development align well with the needs of your team. I would welcome the opportunity to discuss how I can support your goals and contribute to [Company Name]’s continued success.\n\nThank you for considering my application. I look forward to the possibility of contributing to your organization.\n\nSincerely,\n[Your Name]', 1, '2025-07-13 10:47:01', '2025-07-13 10:55:20');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
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
  `status` enum('active','inactive','filled') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `title`, `company`, `location`, `type`, `description`, `requirements`, `salary_range`, `posted_by`, `created_at`, `updated_at`, `status`) VALUES
(1, 'Senior Frontend Developer', 'Google', 'Mountain View, CA', 'full-time', 'Join our team to build the next generation of web applications using React, TypeScript, and modern web technologies. You will work on products used by billions of users worldwide.\r\n\r\nKey Responsibilities:\r\n• Develop user-facing features using React and TypeScript\r\n• Collaborate with UX designers to implement intuitive interfaces\r\n• Optimize applications for maximum speed and scalability\r\n• Participate in code reviews and maintain high code quality standards\r\n• Mentor junior developers and contribute to team growth', '• 5+ years of experience with JavaScript/TypeScript\r\n• Expert knowledge of React, Redux, and modern frontend frameworks\r\n• Experience with HTML5, CSS3, and responsive design\r\n• Familiarity with testing frameworks (Jest, Cypress)\r\n• Strong problem-solving skills and attention to detail\r\n• Bachelor\'s degree in Computer Science or equivalent experience', '$150,000 - $200,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(2, 'Data Scientist', 'Meta', 'Menlo Park, CA', 'full-time', 'Analyze large-scale datasets to drive product decisions and user insights. Work with cutting-edge ML technologies to solve complex business problems.\r\n\r\nKey Responsibilities:\r\n• Analyze user behavior data to identify trends and insights\r\n• Build predictive models using machine learning algorithms\r\n• Collaborate with product teams to define success metrics\r\n• Create data visualizations and reports for stakeholders\r\n• Design and conduct A/B tests to validate hypotheses', '• MS/PhD in Statistics, Mathematics, Computer Science, or related field\r\n• 3+ years of experience in data science or analytics\r\n• Proficiency in Python, R, and SQL\r\n• Experience with ML libraries (scikit-learn, TensorFlow, PyTorch)\r\n• Strong statistical analysis and hypothesis testing skills\r\n• Experience with big data tools (Spark, Hadoop) preferred', '$140,000 - $180,000', 5, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(3, 'UX/UI Designer', 'Apple', 'Cupertino, CA', 'full-time', 'Design intuitive user experiences for our next-generation products. Collaborate with engineering teams to create beautiful, functional interfaces that delight users.\r\n\r\nKey Responsibilities:\r\n• Create wireframes, prototypes, and high-fidelity designs\r\n• Conduct user research and usability testing\r\n• Collaborate with product managers and engineers\r\n• Maintain design systems and component libraries\r\n• Present design concepts to stakeholders', '• 4+ years of UX/UI design experience\r\n• Proficiency in Figma, Sketch, and prototyping tools\r\n• Strong understanding of design principles and best practices\r\n• Experience with user research and usability testing\r\n• Portfolio demonstrating excellent design work\r\n• Bachelor\'s degree in Design, HCI, or related field', '$120,000 - $160,000', 6, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(4, 'Backend Engineer', 'Netflix', 'Los Gatos, CA', 'full-time', 'Build scalable microservices and APIs that serve millions of users. Work with Java, Python, and cloud technologies to power the Netflix streaming platform.\r\n\r\nKey Responsibilities:\r\n• Design and implement RESTful APIs and microservices\r\n• Optimize database performance and query efficiency\r\n• Implement caching strategies and distributed systems\r\n• Monitor system performance and troubleshoot issues\r\n• Collaborate with frontend teams on API integration', '• 4+ years of backend development experience\r\n• Strong proficiency in Java, Python, or similar languages\r\n• Experience with Spring Boot, Django, or equivalent frameworks\r\n• Knowledge of databases (MySQL, PostgreSQL, NoSQL)\r\n• Understanding of microservices architecture\r\n• Experience with cloud platforms (AWS, GCP, Azure)', '$130,000 - $170,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(5, 'DevOps Engineer', 'Amazon', 'Seattle, WA', 'full-time', 'Manage and automate cloud infrastructure using AWS services. Implement CI/CD pipelines and monitoring solutions to ensure reliable service delivery.\r\n\r\nKey Responsibilities:\r\n• Design and maintain AWS cloud infrastructure\r\n• Implement CI/CD pipelines using Jenkins, GitLab CI, or similar\r\n• Monitor system performance and implement alerting\r\n• Automate deployment processes and infrastructure provisioning\r\n• Ensure security best practices and compliance', '• 3+ years of DevOps or Infrastructure experience\r\n• Strong knowledge of AWS services (EC2, S3, RDS, Lambda)\r\n• Experience with containerization (Docker, Kubernetes)\r\n• Proficiency in scripting languages (Bash, Python)\r\n• Knowledge of Infrastructure as Code (Terraform, CloudFormation)\r\n• Experience with monitoring tools (CloudWatch, Prometheus)', '$125,000 - $165,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(6, 'Mobile Developer', 'Uber', 'San Francisco, CA', 'full-time', 'Develop iOS and Android applications using Swift, Kotlin, and React Native. Work on features used by millions of riders and drivers worldwide.\r\n\r\nKey Responsibilities:\r\n• Develop native mobile applications for iOS and Android\r\n• Implement real-time features like GPS tracking and messaging\r\n• Optimize app performance and user experience\r\n• Collaborate with backend teams on API integration\r\n• Participate in app store submission and release processes', '• 3+ years of mobile development experience\r\n• Proficiency in Swift (iOS) and/or Kotlin (Android)\r\n• Experience with React Native or Flutter\r\n• Knowledge of mobile app architecture patterns\r\n• Understanding of RESTful APIs and GraphQL\r\n• Experience with app store guidelines and submission process', '$115,000 - $155,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(7, 'Product Manager', 'Spotify', 'New York, NY', 'full-time', 'Lead product strategy and roadmap for music streaming features. Collaborate with design and engineering teams to deliver exceptional user experiences.\r\n\r\nKey Responsibilities:\r\n• Define product vision and strategy for assigned features\r\n• Conduct market research and competitive analysis\r\n• Collaborate with cross-functional teams to deliver products\r\n• Analyze user feedback and usage metrics\r\n• Manage product roadmap and prioritize features', '• 4+ years of product management experience\r\n• Strong analytical and problem-solving skills\r\n• Experience with agile development methodologies\r\n• Understanding of user research and data analysis\r\n• Excellent communication and leadership skills\r\n• Bachelor\'s degree in Business, Engineering, or related field', '$130,000 - $170,000', 5, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(8, 'Machine Learning Engineer', 'Tesla', 'Palo Alto, CA', 'full-time', 'Develop autonomous driving algorithms and computer vision systems. Work with TensorFlow, PyTorch, and advanced ML techniques to power self-driving technology.\r\n\r\nKey Responsibilities:\r\n• Develop computer vision algorithms for autonomous vehicles\r\n• Train and optimize deep learning models\r\n• Process and analyze large datasets from vehicle sensors\r\n• Collaborate with hardware teams on sensor integration\r\n• Implement real-time inference systems', '• MS/PhD in Computer Science, AI, or related field\r\n• 3+ years of ML engineering experience\r\n• Expert knowledge of TensorFlow, PyTorch, and OpenCV\r\n• Experience with computer vision and deep learning\r\n• Understanding of autonomous systems and robotics\r\n• Strong programming skills in Python and C++', '$160,000 - $220,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(9, 'React Developer', 'Airbnb', 'San Francisco, CA', 'contract', 'Build responsive web applications using React, Redux, and modern JavaScript. 6-month contract with possibility of full-time conversion.\r\n\r\nKey Responsibilities:\r\n• Develop new user-facing features using React\r\n• Build reusable components and front-end libraries\r\n• Translate designs into high-quality code\r\n• Optimize components for maximum performance\r\n• Collaborate with design and backend teams', '• 2+ years of React development experience\r\n• Strong proficiency in JavaScript (ES6+) and TypeScript\r\n• Experience with Redux, Context API, and React Hooks\r\n• Knowledge of CSS preprocessors and styling frameworks\r\n• Familiarity with testing libraries (Jest, React Testing Library)\r\n• Understanding of responsive design principles', '$80 - $120 per hour', 6, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(10, 'Software Engineer Intern', 'Adobe', 'San Jose, CA', 'internship', 'Summer internship program for computer science students. Work on real projects with mentorship from senior engineers on Creative Cloud products.\r\n\r\nKey Responsibilities:\r\n• Contribute to feature development under mentorship\r\n• Participate in code reviews and team meetings\r\n• Learn industry best practices and development workflows\r\n• Present project results to team and stakeholders\r\n• Collaborate with other interns on group projects', '• Currently pursuing BS/MS in Computer Science or related field\r\n• Strong programming skills in Java, Python, or JavaScript\r\n• Understanding of data structures and algorithms\r\n• Excellent problem-solving and communication skills\r\n• Passion for technology and software development\r\n• Previous internship or project experience preferred', '$6,000 - $8,000 per month', 6, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(11, 'Remote Full Stack Developer', 'GitLab', 'Remote', 'remote', 'Build and maintain web applications using Ruby on Rails and Vue.js. Fully remote position with flexible working hours in a globally distributed team.\r\n\r\nKey Responsibilities:\r\n• Develop features across the full technology stack\r\n• Participate in code reviews and pair programming sessions\r\n• Contribute to open-source GitLab project\r\n• Collaborate with team members across different time zones\r\n• Maintain and improve existing codebase', '• 3+ years of full-stack development experience\r\n• Proficiency in Ruby on Rails and Vue.js\r\n• Experience with PostgreSQL and Redis\r\n• Understanding of Git and GitLab workflows\r\n• Strong communication skills for remote collaboration\r\n• Self-motivated and able to work independently', '$90,000 - $130,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(12, 'QA Engineer', 'Slack', 'San Francisco, CA', 'full-time', 'Ensure software quality through manual and automated testing. Develop test strategies and work closely with development teams to deliver bug-free products.\r\n\r\nKey Responsibilities:\r\n• Design and execute comprehensive test plans\r\n• Develop automated test suites using Selenium/Cypress\r\n• Perform manual testing for new features and bug fixes\r\n• Report and track defects using JIRA\r\n• Collaborate with developers on testing best practices', '• 3+ years of QA/Testing experience\r\n• Experience with automated testing tools (Selenium, Cypress)\r\n• Knowledge of testing methodologies and best practices\r\n• Strong analytical and problem-solving skills\r\n• Experience with bug tracking tools (JIRA, Bugzilla)\r\n• Understanding of agile development processes', '$95,000 - $125,000', 4, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(13, 'Business Analyst', 'Oracle', 'Redwood City, CA', 'full-time', 'Analyze business requirements and translate them into technical specifications. Work with stakeholders to improve business processes and system efficiency.\r\n\r\nKey Responsibilities:\r\n• Gather and document business requirements\r\n• Analyze current business processes and identify improvements\r\n• Create functional specifications for development teams\r\n• Facilitate meetings between business and technical teams\r\n• Perform user acceptance testing and training', '• 3+ years of business analysis experience\r\n• Strong analytical and documentation skills\r\n• Experience with requirements gathering and process modeling\r\n• Knowledge of SQL and data analysis tools\r\n• Excellent communication and stakeholder management skills\r\n• Bachelor\'s degree in Business, IT, or related field', '$85,000 - $115,000', 6, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(14, 'Game Developer', 'Electronic Arts', 'Redwood City, CA', 'full-time', 'Develop video games using Unity and C#. Work on AAA titles played by millions of gamers worldwide with a focus on gameplay mechanics and user experience.\r\n\r\nKey Responsibilities:\r\n• Design and implement gameplay features using Unity\r\n• Create interactive systems and game mechanics\r\n• Optimize game performance for multiple platforms\r\n• Collaborate with artists and designers on game assets\r\n• Debug and fix gameplay issues', '• 3+ years of game development experience\r\n• Expert knowledge of Unity and C#\r\n• Understanding of game design principles and patterns\r\n• Experience with version control systems (Perforce, Git)\r\n• Knowledge of 3D graphics and animation systems\r\n• Portfolio of shipped games or game projects', '$100,000 - $140,000', 5, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(15, 'Content Writer', 'Medium', 'San Francisco, CA', 'part-time', 'Create engaging content for our platform and marketing channels. Flexible part-time position with remote work options and creative freedom.\r\n\r\nKey Responsibilities:\r\n• Write blog posts, articles, and marketing copy\r\n• Research industry trends and create thought leadership content\r\n• Edit and proofread content from other writers\r\n• Collaborate with marketing team on content strategy\r\n• Optimize content for SEO and social media', '• 2+ years of professional writing experience\r\n• Excellent writing and editing skills\r\n• Understanding of SEO and content marketing\r\n• Experience with CMS platforms and publishing tools\r\n• Strong research and interviewing skills\r\n• Portfolio of published writing work', '$25 - $40 per hour', 5, '2025-07-12 09:55:02', '2025-07-12 09:55:02', 'active'),
(16, 'Software Engineer', 'Sentosa Company', 'Tanjung Malim', 'full-time', 'Reti coding pandai coding', 'Degree', '1000-2000', 10, '2025-07-12 12:39:38', '2025-07-12 12:39:38', 'active');

-- --------------------------------------------------------

--
-- Stand-in structure for view `jobs_with_stats`
-- (See below for the actual view)
--
CREATE TABLE `jobs_with_stats` (
`id` int(11)
,`title` varchar(255)
,`company` varchar(255)
,`location` varchar(255)
,`type` varchar(50)
,`description` text
,`requirements` text
,`salary_range` varchar(100)
,`posted_by` int(11)
,`created_at` timestamp
,`updated_at` timestamp
,`posted_by_name` varchar(201)
,`posted_by_company` varchar(255)
,`application_count` bigint(21)
,`pending_applications` bigint(21)
,`reviewed_applications` bigint(21)
,`accepted_applications` bigint(21)
,`rejected_applications` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `job_applications_view`
-- (See below for the actual view)
--
CREATE TABLE `job_applications_view` (
`application_id` int(11)
,`status` enum('pending','reviewed','accepted','rejected')
,`applied_date` timestamp
,`cover_letter` text
,`first_name` varchar(100)
,`last_name` varchar(100)
,`email` varchar(255)
,`phone` varchar(20)
,`job_id` int(11)
,`title` varchar(255)
,`company` varchar(255)
,`location` varchar(255)
,`type` varchar(50)
,`salary_range` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `job_seeker_profiles`
-- (See below for the actual view)
--
CREATE TABLE `job_seeker_profiles` (
`id` int(11)
,`first_name` varchar(100)
,`last_name` varchar(100)
,`email` varchar(255)
,`phone` varchar(20)
,`assessment_score` decimal(5,2)
,`assessment_completed` tinyint(1)
,`assessment_date` timestamp
,`member_since` timestamp
,`assessment_level` varchar(17)
);

-- --------------------------------------------------------

--
-- Table structure for table `saved_jobs`
--

CREATE TABLE `saved_jobs` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `saved_jobs`
--

INSERT INTO `saved_jobs` (`id`, `job_id`, `user_id`, `created_at`) VALUES
(1, 1, 1, '2025-07-12 09:55:02'),
(2, 2, 1, '2025-07-12 09:55:02'),
(3, 6, 1, '2025-07-12 09:55:02'),
(4, 3, 2, '2025-07-12 09:55:02'),
(5, 7, 2, '2025-07-12 09:55:02'),
(6, 4, 3, '2025-07-12 09:55:02'),
(7, 8, 3, '2025-07-12 09:55:02'),
(8, 1, 8, '2025-07-12 09:57:49'),
(9, 2, 8, '2025-07-12 09:57:50');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
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
  `email_verified` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `firebase_uid`, `email`, `password`, `first_name`, `last_name`, `role`, `phone`, `assessment_score`, `assessment_completed`, `assessment_date`, `resume_url`, `company_name`, `created_at`, `updated_at`, `profile_picture`, `email_verified`) VALUES
(1, NULL, 'john.doe@email.com', '1', 'John', 'Doe', 'job_seeker', '+1-555-0101', NULL, 0, NULL, NULL, NULL, '2025-07-12 09:55:02', '2025-07-12 09:56:42', NULL, 0),
(2, NULL, 'jane.smith@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jane', 'Smith', 'job_seeker', '+1-555-0102', NULL, 0, NULL, NULL, NULL, '2025-07-12 09:55:02', '2025-07-12 09:55:02', NULL, 0),
(3, NULL, 'mike.johnson@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mike', 'Johnson', 'job_seeker', '+1-555-0103', NULL, 0, NULL, NULL, NULL, '2025-07-12 09:55:02', '2025-07-12 09:55:02', NULL, 0),
(4, NULL, 'hr@google.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sarah', 'Wilson', 'employer', '+1-555-0201', NULL, 0, NULL, NULL, 'Google', '2025-07-12 09:55:02', '2025-07-12 09:55:02', NULL, 0),
(5, NULL, 'recruiter@meta.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'David', 'Brown', 'employer', '+1-555-0202', NULL, 0, NULL, NULL, 'Meta', '2025-07-12 09:55:02', '2025-07-12 09:55:02', NULL, 0),
(6, NULL, 'hiring@apple.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Lisa', 'Davis', 'employer', '+1-555-0203', NULL, 0, NULL, NULL, 'Apple', '2025-07-12 09:55:02', '2025-07-12 09:55:02', NULL, 0),
(7, NULL, 'admin@jobseeker.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', 'User', 'admin', '+1-555-0001', NULL, 0, NULL, NULL, 'Job Seeker Platform', '2025-07-12 09:55:02', '2025-07-12 09:55:02', NULL, 0),
(8, NULL, 'raziq@gmail.com', '$2b$10$8pq0qtqehGM2q4ZBXbr.4.0xxytrSh6YwNL74tK4gOIngpFh9NP.6', 'Raziq', 'Shafiee', 'job_seeker', '0122274125', 33.00, 1, '2025-07-13 10:45:45', NULL, NULL, '2025-07-12 09:57:15', '2025-07-13 10:45:45', NULL, 0),
(9, NULL, 'raziqemp@gmail.com', '$2b$10$42eYudt.MTfEZWnP4sZwu.Hr1ny5WRIu3skgpYgl/8HFbSfdb.jtS', 'Raziq', 'Shafiee', 'employer', '', NULL, 0, NULL, NULL, 'UBER', '2025-07-12 12:17:06', '2025-07-12 12:17:06', NULL, 0),
(10, NULL, 'ashraf@company.com', '$2b$10$NEtVHCr6GjHPH05xGm75s.L8J4GWm4IYM1okOWtMKec1KlhzhYa5m', 'Ash', 'AI', 'employer', '+1231231231', NULL, 0, NULL, NULL, 'Tech Solutions Inc', '2025-07-12 12:24:35', '2025-07-12 12:24:35', NULL, 0),
(11, NULL, 'azfar@gmail.com', '$2b$10$CHLRwJlHEKIpBHif2tqaO.IO7Q4C2Fo9w8aDVJ.RyONuUd3v2mike', 'Azfar', 'Roslan', 'job_seeker', NULL, 40.00, 1, '2025-07-12 19:11:03', NULL, NULL, '2025-07-12 17:48:13', '2025-07-12 19:11:03', NULL, 0),
(12, 'BPWXouQmCibeME1fHkJY2Da3Mis1', 'babyshark1227@gmail.com', NULL, 'BaBY', 'Shark', 'employer', NULL, NULL, 0, NULL, NULL, NULL, '2025-07-13 14:18:31', '2025-07-13 14:18:31', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `user_assessments`
--

CREATE TABLE `user_assessments` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_questions` int(11) NOT NULL DEFAULT 15,
  `correct_answers` int(11) NOT NULL,
  `total_points` int(11) NOT NULL,
  `max_possible_points` int(11) NOT NULL DEFAULT 150,
  `percentage_score` decimal(5,2) NOT NULL,
  `time_taken_seconds` int(11) DEFAULT NULL,
  `skill_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`skill_scores`)),
  `user_answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`user_answers`)),
  `completed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_assessments`
--

INSERT INTO `user_assessments` (`id`, `user_id`, `total_questions`, `correct_answers`, `total_points`, `max_possible_points`, `percentage_score`, `time_taken_seconds`, `skill_scores`, `user_answers`, `completed_at`) VALUES
(3, 11, 15, 6, 60, 150, 40.00, 18, '{\"Problem Solving\":{\"correct\":2,\"total\":3},\"Communication\":{\"correct\":1,\"total\":3},\"Adaptability\":{\"correct\":1,\"total\":3},\"Time Management\":{\"correct\":1,\"total\":3},\"Professional Ethics\":{\"correct\":1,\"total\":3}}', '[{\"questionId\":1,\"selectedAnswer\":\"C\"},{\"questionId\":2,\"selectedAnswer\":\"B\"},{\"questionId\":3,\"selectedAnswer\":\"A\"},{\"questionId\":4,\"selectedAnswer\":\"D\"},{\"questionId\":5,\"selectedAnswer\":\"B\"},{\"questionId\":6,\"selectedAnswer\":\"D\"},{\"questionId\":7,\"selectedAnswer\":\"D\"},{\"questionId\":8,\"selectedAnswer\":\"B\"},{\"questionId\":9,\"selectedAnswer\":\"C\"},{\"questionId\":10,\"selectedAnswer\":\"B\"},{\"questionId\":11,\"selectedAnswer\":\"D\"},{\"questionId\":12,\"selectedAnswer\":\"A\"},{\"questionId\":13,\"selectedAnswer\":\"D\"},{\"questionId\":14,\"selectedAnswer\":\"B\"},{\"questionId\":15,\"selectedAnswer\":\"C\"}]', '2025-07-12 19:11:03'),
(4, 8, 15, 5, 50, 150, 33.00, 18, '{\"Problem Solving\":{\"correct\":0,\"total\":3},\"Communication\":{\"correct\":1,\"total\":3},\"Adaptability\":{\"correct\":2,\"total\":3},\"Time Management\":{\"correct\":0,\"total\":3},\"Professional Ethics\":{\"correct\":2,\"total\":3}}', '[{\"questionId\":1,\"selectedAnswer\":\"A\"},{\"questionId\":2,\"selectedAnswer\":\"D\"},{\"questionId\":3,\"selectedAnswer\":\"C\"},{\"questionId\":4,\"selectedAnswer\":\"B\"},{\"questionId\":5,\"selectedAnswer\":\"D\"},{\"questionId\":6,\"selectedAnswer\":\"C\"},{\"questionId\":7,\"selectedAnswer\":\"B\"},{\"questionId\":8,\"selectedAnswer\":\"D\"},{\"questionId\":9,\"selectedAnswer\":\"B\"},{\"questionId\":10,\"selectedAnswer\":\"C\"},{\"questionId\":11,\"selectedAnswer\":\"A\"},{\"questionId\":12,\"selectedAnswer\":\"D\"},{\"questionId\":13,\"selectedAnswer\":\"B\"},{\"questionId\":14,\"selectedAnswer\":\"D\"},{\"questionId\":15,\"selectedAnswer\":\"B\"}]', '2025-07-13 10:45:45');

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
DROP TABLE IF EXISTS `jobs_with_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `jobs_with_stats`  AS SELECT `j`.`id` AS `id`, `j`.`title` AS `title`, `j`.`company` AS `company`, `j`.`location` AS `location`, `j`.`type` AS `type`, `j`.`description` AS `description`, `j`.`requirements` AS `requirements`, `j`.`salary_range` AS `salary_range`, `j`.`posted_by` AS `posted_by`, `j`.`created_at` AS `created_at`, `j`.`updated_at` AS `updated_at`, concat(`u`.`first_name`,' ',`u`.`last_name`) AS `posted_by_name`, `u`.`company_name` AS `posted_by_company`, count(`a`.`id`) AS `application_count`, count(case when `a`.`status` = 'pending' then 1 end) AS `pending_applications`, count(case when `a`.`status` = 'reviewed' then 1 end) AS `reviewed_applications`, count(case when `a`.`status` = 'accepted' then 1 end) AS `accepted_applications`, count(case when `a`.`status` = 'rejected' then 1 end) AS `rejected_applications` FROM ((`jobs` `j` left join `users` `u` on(`j`.`posted_by` = `u`.`id`)) left join `applications` `a` on(`j`.`id` = `a`.`job_id`)) GROUP BY `j`.`id` ORDER BY `j`.`created_at` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `job_applications_view`
--
DROP TABLE IF EXISTS `job_applications_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `job_applications_view`  AS SELECT `a`.`id` AS `application_id`, `a`.`status` AS `status`, `a`.`created_at` AS `applied_date`, `a`.`cover_letter` AS `cover_letter`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, `u`.`phone` AS `phone`, `j`.`id` AS `job_id`, `j`.`title` AS `title`, `j`.`company` AS `company`, `j`.`location` AS `location`, `j`.`type` AS `type`, `j`.`salary_range` AS `salary_range` FROM ((`applications` `a` join `users` `u` on(`a`.`user_id` = `u`.`id`)) join `jobs` `j` on(`a`.`job_id` = `j`.`id`)) ORDER BY `a`.`created_at` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `job_seeker_profiles`
--
DROP TABLE IF EXISTS `job_seeker_profiles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `job_seeker_profiles`  AS SELECT `u`.`id` AS `id`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, `u`.`phone` AS `phone`, `u`.`assessment_score` AS `assessment_score`, `u`.`assessment_completed` AS `assessment_completed`, `u`.`assessment_date` AS `assessment_date`, `u`.`created_at` AS `member_since`, CASE WHEN `u`.`assessment_score` >= 90 THEN 'Excellent' WHEN `u`.`assessment_score` >= 80 THEN 'Very Good' WHEN `u`.`assessment_score` >= 70 THEN 'Good' WHEN `u`.`assessment_score` >= 60 THEN 'Satisfactory' WHEN `u`.`assessment_score` < 60 THEN 'Needs Improvement' ELSE 'Not Assessed' END AS `assessment_level` FROM `users` AS `u` WHERE `u`.`role` = 'job_seeker' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_application` (`job_id`,`user_id`),
  ADD KEY `idx_job_id` (`job_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_applications_status_created` (`status`,`created_at`),
  ADD KEY `idx_requires_assessment` (`requires_assessment`),
  ADD KEY `idx_applications_user_job` (`user_id`,`job_id`),
  ADD KEY `idx_applications_status` (`status`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_title` (`title`),
  ADD KEY `idx_company` (`company`),
  ADD KEY `idx_location` (`location`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_posted_by` (`posted_by`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_jobs_type_location` (`type`,`location`),
  ADD KEY `idx_jobs_company_created` (`company`,`created_at`),
  ADD KEY `idx_jobs_posted_by` (`posted_by`),
  ADD KEY `idx_jobs_status` (`status`);
ALTER TABLE `jobs` ADD FULLTEXT KEY `idx_search_content` (`title`,`company`,`location`,`description`);

--
-- Indexes for table `saved_jobs`
--
ALTER TABLE `saved_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_saved_job` (`job_id`,`user_id`),
  ADD KEY `idx_job_id` (`job_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `firebase_uid` (`firebase_uid`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_users_role_created` (`role`,`created_at`),
  ADD KEY `idx_assessment_score` (`assessment_score`),
  ADD KEY `idx_assessment_completed` (`assessment_completed`),
  ADD KEY `idx_users_assessment_combo` (`assessment_completed`,`assessment_score`),
  ADD KEY `idx_firebase_uid` (`firebase_uid`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_assessment` (`assessment_completed`,`assessment_score`);

--
-- Indexes for table `user_assessments`
--
ALTER TABLE `user_assessments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_assessment` (`user_id`),
  ADD KEY `idx_percentage_score` (`percentage_score`),
  ADD KEY `idx_assessments_score_desc` (`percentage_score`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `saved_jobs`
--
ALTER TABLE `saved_jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `user_assessments`
--
ALTER TABLE `user_assessments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `jobs`
--
ALTER TABLE `jobs`
  ADD CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `saved_jobs`
--
ALTER TABLE `saved_jobs`
  ADD CONSTRAINT `saved_jobs_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `saved_jobs_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_assessments`
--
ALTER TABLE `user_assessments`
  ADD CONSTRAINT `user_assessments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
