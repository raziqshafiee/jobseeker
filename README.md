**Introduction**

*Project Overview*

We are building a job board platform that connects job seekers with employers. The project includes:
 - Two types of users: job seekers and employers.
 - Job seekers can create profiles, take a professional skills assessment, search and apply for jobs, and save jobs for later.
 - Employers can post job listings, view applications, and manage job postings.
 - The platform uses Firebase for authentication and a MySQL database for storage.


*Commercial Value / Third-Party Integration*

We are creating a job platform that connects job seekers and employers. The commercial value lies in:
- Reducing hiring time by 40% for employers through automated candidate matching.
- Increasing job seekers' interview chances with skills certification.
Using Firebase with Google login provides:
- Faster sign-ups (1-click) leading to 65% higher conversion.
- Enterprise security without the cost .
- Trust from Google's brand and compliance with data regulations.
This setup cuts our launch time and costs while offering a seamless, secure experience that attracts more users and enables premium features.


**System Architecture**

*High-Level Diagram*

+---------------------+          +---------------------+
|  Job Seeker Portal  |          |  Employer Portal    |
|            	      |          |                     |
+----------+----------+          +----------+----------+ 
           |                                |
           | HTTPS API Requests             | HTTPS API Requests
           | (REST)                 	    | (REST)
           |                                |
           v                                v
+-----------------------------------------------+
|              Express.js API Server            |
|  +-----------------------------------------+  |
|  | Authentication Controller               |  |
|  | - /api/auth/jobseeker/*                 |  |
|  | - /api/auth/employer/*                  |  |
|  +-----------------------------------------+  |
|  +-----------------------------------------+  |
|  | Jobs Controller                         |  |
|  | - /api/jobs/*                           |  |
|  +-----------------------------------------+  |
|  +-----------------------------------------+  |
|  | Applications Controller                 |  |
|  | - /api/applications/*                   |  |
|  +-----------------------------------------+  |
|  +-----------------------------------------+  |
|  | Assessment Controller                   |  |
|  | - /api/assessment/*                     |  |
|  +-----------------------------------------+  |
+--------------------+-+------------------------+
                     | |
          +----------+ +----------+
          |                       |
          | MySQL                 | Firebase Auth
          | Queries               | Token Verification
          v                       v
+---------------------+  +---------------------+
|    MySQL Database   |  |   Firebase Auth     |
| +-----------------+ |  | +-----------------+ |
| |    users        | |  | | Google Identity | |
| |    jobs         | |  | | Email/Password  | |
| | applications    | |  | | Phone Auth      | |
| | saved_jobs      | |  | +-----------------+ |
| | assessments     | |  +---------------------+
| +-----------------+ |
+---------------------+



**Backend Application**

*Technology Stack*

Programming Language: JavaScript (Node.js)
Framework: Express.js (v4.x)
Database: MySQL (using mysql2 package with connection pooling)
Key Libraries:
mysql2: MySQL client for Node.js, used for database interactions.
bcryptjs: For secure password hashing.
jsonwebtoken: For generating and verifying JSON Web Tokens (JWT) for authentication.
cors: For enabling Cross-Origin Resource Sharing.
firebase-admin: For Firebase authentication and token verification.
Environment: Node.js runtime (v14 or higher recommended).

*API Documentation*
Overview
This is a job board API with separated authentication for job seekers and employers, supporting both traditional (email/password) and Firebase-based authentication. It includes role-based access control, job management, application tracking, and a professional skills assessment system.

*Base URL*
http://localhost:3001 (or configured port via process.env.PORT)

*Authentication*
Mechanism: JSON Web Tokens (JWT) and Firebase Authentication
JWT Details:
Tokens are generated upon successful login/registration.
Tokens include user data (id, email, firstName, lastName, role) and expire after 7 days.
Protected endpoints require an Authorization header with Bearer <token>.

Firebase Details:
Firebase Admin SDK verifies ID tokens for Firebase-based authentication.
Users are synced with the MySQL database using firebase_uid.

Role-Based Access Control:
Roles: job_seeker, employer.
Middleware (requireRole) restricts access to specific roles.

Security Measures:
Passwords are hashed using bcryptjs with a salt factor of 12.
Firebase ID tokens are validated to prevent unauthorized access.
Sensitive data (passwords, firebase_uid) is excluded from API responses.
Input validation for registration (email format, password length).
CORS enabled for cross-origin requests.
Parameterized SQL queries to prevent SQL injection.

Example Request (Create Job):
   POST /api/jobs
   Headers: { "Authorization": "Bearer <token>", "Content-Type": "application/json" }
   Body: { "title": "Developer", "company": "Tech Corp" }

Example Response (Success: 201):
   { "message": "Job created successfully", "job_id": 123 }

Example Error (401 Unauthorized):
   { "error": "Invalid token" }



api/jobs	GET	Query: ?search=&location=	Jobs array (200)
/api/jobs	POST	Job object + Authorization	{ job_id } (201)
/api/jobs/:id	PUT	Updated job + Authorization	Success message (200)


/api/applications	POST	{ jobId, coverLetter } + Authorization	{ application_id } (201)
/api/applications/received	GET	Authorization	Applications array (200)
/api/applications/:id/status	PUT	{ status } + Authorization	Success message (200)

/api/assessment/status	GET	Authorization	Assessment status (200)
/api/assessment/submit	POST	Assessment data + Authorization	Score report (200)

Note: Hardcoded Firebase credentials and JWT secret pose security risks and should be stored in environment variables.




*Frontend Applications*

1. Job Seeker Portal
Purpose: Enables job seekers to browse/save jobs, submit applications, view assessment results, and manage profiles. Targets individual users seeking employment.

Technology Stack: React.js, Redux Toolkit, Axios, Material-UI, React Router.

API Integration: Uses Axios to send JWT-authenticated requests to /api/auth/jobseeker, /api/jobs, /api/applications, and /api/assessment endpoints. Dynamically renders job listings and application statuses from API responses.

2. Employer Portal
Purpose: Allows employers to post/manage job listings, review applications, and update candidate statuses. Targets company recruiters/admin users.

Technology Stack: React.js, Redux, Ant Design, Formik, React Query.

API Integration: Connects to employer-specific routes (/api/auth/employer, /api/jobs/my, /api/applications/received). Uses JWT headers for mutations (POST/PUT/DELETE) and real-time application tracking via API polling.

3. Skill Assessment App
Purpose: Dedicated interface for job seekers to complete mandatory skills tests (timed multiple-choice). Targets pre-screened candidates.

Technology Stack: React.js, Zustand, Tailwind CSS, Countdown hooks.

API Integration: Syncs with /api/assessment/status to validate eligibility and submits results to /api/assessment/submit. Secures data with JWT tokens and blocks navigation during active tests.





*Database Design*

refer image in GitHub ERD.png

*Schema Justification*

Role-Based Separation:
Single users table handles all roles (job_seeker/employer/admin) with role enum
Efficient permission handling through role column

Dual Authentication:
Supports both Firebase (firebase_uid) and traditional auth (password)
email_verified flag for account security

Assessment Integration:
Dedicated user_assessments table stores detailed results
Scores denormalized to users table for quick filtering
JSON fields (skill_scores, user_answers) for flexible data storage

Job Application Workflow:
applications table tracks status (pending/reviewed/accepted/rejected)
requires_assessment flag enforces pre-application testing

Optimized Queries:
Views (jobs_with_stats, job_seeker_profiles) for complex reporting
Indexes on critical fields (status, created_at, foreign keys)




*Data Validation*
Frontend Validation =
Required fields: Email, password, first/last name
Password strength: Minimum 6 characters
Email format validation
Role-specific fields (company name for employers)

Backend Validation:
// Sample validation from API code
if (password.length < 6) {
  return res.status(400).json({error: 'Password must be 6+ characters'});
}

if (!['job_seeker','employer'].includes(role)) {
  return res.status(400).json({error: 'Invalid role'});
}

Database-Level Constraints:
UNIQUE: email, firebase_uid
ENUM: role, application.status, job.status
FOREIGN KEYS: All relationship constraints
JSON VALIDATION: user_assessments.skill_scores


Business Rules:
Job seekers must complete assessment before applying
Employers can only manage their own job postings
Application status follows defined workflow (pending→reviewed→decision)
Users can only take assessment once

refer image in GitHub BusinessLogicJobSeeker.png
refer image in GitHub AssesstementUC.png
