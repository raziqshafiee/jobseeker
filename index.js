const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
const port = process.env.PORT || 3001;

// Configuration
const JWT_SECRET = process.env.JWT_SECRET || 'your-jwt-secret';
const DB_CONFIG = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'jobseeker'
};

// Initialize Firebase Admin SDK
const serviceAccount = {
    type: "service_account",
    project_id: "jobseeker-655c1",
    private_key_id: "a4fdb3131d4f1f2dc3fbb8c3f59671b3c875086b",
    private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCikZVM9lxjlBlk\nsRfUb8bLIBwQeYBNwXUuuTIn0PD8EruIWlM2rM+SmevyUlJo6S0ZerEPa5Pjcy6j\nuwIDmcsgu/Y9IKk8zlFUolxl+YLUkCJHk85W+NtXgplsBu7QvmFrjuXQgRKGzkZ+\nxerCFnCM8D1TEX/ll6osanRiw+UzANU6H9unYnkvCIrzY27kXBeL+K/9WoNfW5vg\ngZkB6C8YBHy6LSdIqvj+7uxeoE68TnTeNf6OvlP56qwV13Jx2IULSfOEcv+bVeh6\nWc0YFppart6AHS9N04EKgF2OmoS3T1kw5Zaf2XLowDZbtPA/n/HmcvRbAtycs2zQ\nsk2PrdqdAgMBAAECggEAClpTmVBfdK76iVf20Mj32Q6NLaZohkB2841d3+fAOl6r\nXIUGDhy7ZlZmOSscGOwakBK+bQvjNzr/V3QiGMkbRL/Q8AvLrfXkpjYQb3plkMmy\nCSq6Rf3N+CN2x535vkeVgX7wQeg/s1/hC5M+k/LPuEYCCG98RzUypDv49/jfjdvF\nHfkVFCnSakzVWZttxrd47shhm/0VbJT91Jje2/0FBtU82jQHYom5KO0K16DJQs1N\nPGRPozacFag8nCjUPKzcb+BtifGnmbkFzB3+2pURrBhKYz8DE7xu8/0Z7qwJKPGo\npZ7Y2R4Vdwa3M+8zlmtveWp6Nxc3AomNM1uuKOWKIQKBgQDXJIrOvJ1zt7sxSXeE\nZqsueiux/IL+9O8FPMNALJLIWvy+aCZ6EVE9585AaEf08NatjExHo0ZIGg7MU+Mm\n9T2PO4VwpvsyqiyxFltlkELNqrcTTx5lYEZ3VmRVfTvxStuzbPK0vGB2wmBuPikC\nC+VUu9m/OWHsAOXYNv+t8msf4QKBgQDBcRTZubsQfTtJg9gXKB05d95gwrhSaOqV\nGclpNtPs/G1vlhU9MXnRqfLXPHOvCLxbgui3SpwXAE1qQq+4U3JNKwrA8nwglYt9\nNy2xXJQUQkws+PA2G6/TU7FZTHH2xGVxMRMp3GHJ+T+z/10mBxgDTwatjKMte0O1\nVHBcoNeCPQKBgDYX7Aa7CeO0iI6F6FUT82qGMUJZOR6duxNYCcey7V0O84l0amg6\nvnCQPh2XmrANdgzAv9UrSlqKornhRbXf55CB6LVAZtyASShldKl+si1ABTQHqp7W\nrCEJScTs7gtnRQJCHGwxCRgTG2fcnTb0gr7hVIhuBx7twtywR20XDLRBAoGBAJfe\n7SzHGeunNm3QOk5r6w3cY1X6anYg8tNerHeTWS09PboWzdP+TRLj58k+J+Dq7d62\n13hX9lZEoYLkmksQELQvL8EuX2/BmQMU2CXgdk21g1LnmsgQUqmKkrl2QB8qMC5/\nBfmekZPdwTrTKVGaziqC185XlSE3HoB1q8W9bZVNAoGBAM2RYcpRMniRNcI/SiOI\nP3P0MZeeqGFF0ah/mc9uM+q6NcrISiqkV6YC3+yMHz+dqAxRPfuYlS2Rm1X9QvUL\nVY59+oSPDwxeaHc/RSC23zuhzceuhbEXKZsQnn+0JL2SjG6J5Tq/0vB9F6godODi\nraZKMH4+/Su93iIK+zYd/RP6\n-----END PRIVATE KEY-----\n",
    client_email: "firebase-adminsdk-fbsvc@jobseeker-655c1.iam.gserviceaccount.com",
    client_id: "112313179481158744865",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40jobseeker-655c1.iam.gserviceaccount.com",
    universe_domain: "googleapis.com"
};

// Initialize Firebase Admin
try {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: 'jobseeker-655c1'
    });
    console.log('✅ Firebase Admin initialized successfully');
} catch (error) {
    console.error('❌ Firebase Admin initialization failed:', error.message);
}

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
const pool = mysql.createPool(DB_CONFIG);

// Authentication middleware
const authenticateToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Token required' });
    
    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid token' });
        req.user = user;
        next();
    });
};

// Role-based middleware
const requireRole = (roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
        return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
};

// Helper function to generate JWT token
const generateToken = (user) => {
    return jwt.sign({
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role
    }, JWT_SECRET, { expiresIn: '7d' });
};

// Helper function to find or create user from Firebase
const findOrCreateFirebaseUser = async (firebaseUser, userInfo, expectedRole) => {
    return new Promise((resolve, reject) => {
        // First, try to find existing user by email
        pool.query('SELECT * FROM users WHERE email = ?', [firebaseUser.email], async (err, results) => {
            if (err) return reject(err);
            
            if (results.length > 0) {
                // User exists, update Firebase UID if not set
                const existingUser = results[0];
                
                // Check if user has the expected role
                if (existingUser.role !== expectedRole) {
                    return reject(new Error(`User role mismatch. Expected: ${expectedRole}, Found: ${existingUser.role}`));
                }
                
                if (!existingUser.firebase_uid) {
                    pool.query('UPDATE users SET firebase_uid = ? WHERE id = ?', 
                        [firebaseUser.uid, existingUser.id], (updateErr) => {
                        if (updateErr) console.warn('Could not update Firebase UID:', updateErr);
                    });
                }
                
                resolve(existingUser);
            } else {
                // Create new user with expected role
                const newUser = {
                    email: firebaseUser.email,
                    firebase_uid: firebaseUser.uid,
                    first_name: userInfo.firstName || firebaseUser.displayName?.split(' ')[0] || '',
                    last_name: userInfo.lastName || firebaseUser.displayName?.split(' ').slice(1).join(' ') || '',
                    role: expectedRole,
                    phone: firebaseUser.phoneNumber || null,
                    company_name: userInfo.companyName || null,
                    profile_picture: firebaseUser.photoURL || null,
                    email_verified: firebaseUser.emailVerified || false
                };
                
                const sql = `INSERT INTO users (email, firebase_uid, first_name, last_name, role, phone, 
                           company_name, profile_picture, email_verified) 
                           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;
                
                const values = [
                    newUser.email, newUser.firebase_uid, newUser.first_name, newUser.last_name,
                    newUser.role, newUser.phone, newUser.company_name, newUser.profile_picture, 
                    newUser.email_verified
                ];
                
                pool.query(sql, values, (insertErr, result) => {
                    if (insertErr) return reject(insertErr);
                    
                    resolve({
                        id: result.insertId,
                        ...newUser
                    });
                });
            }
        });
    });
};

// ==================== AUTH ROUTES ====================

// Job Seeker Firebase Login/Register
app.post('/api/auth/jobseeker/firebase-login', async (req, res) => {
    try {
        const { idToken, userInfo = {} } = req.body;
        
        if (!idToken) {
            return res.status(400).json({ error: 'Firebase ID token required' });
        }
        
        // Verify the Firebase ID token
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const firebaseUser = decodedToken;
        
        // Find or create user in database (enforce job_seeker role)
        const user = await findOrCreateFirebaseUser(firebaseUser, userInfo, 'job_seeker');
        
        // Generate JWT token
        const token = generateToken(user);
        
        // Remove sensitive data
        const { password, firebase_uid, ...safeUser } = user;
        
        res.json({
            message: 'Job seeker Firebase authentication successful',
            token,
            user: safeUser,
            authMethod: 'firebase'
        });
        
    } catch (error) {
        console.error('Job seeker Firebase auth error:', error);
        
        if (error.message.includes('User role mismatch')) {
            return res.status(403).json({ 
                error: 'This account is registered as an employer. Please use the Employer Portal.',
                userRole: 'employer'
            });
        }
        
        if (error.code === 'auth/id-token-expired') {
            return res.status(401).json({ error: 'Firebase token expired' });
        } else if (error.code === 'auth/id-token-revoked') {
            return res.status(401).json({ error: 'Firebase token revoked' });
        } else if (error.code === 'auth/invalid-id-token') {
            return res.status(401).json({ error: 'Invalid Firebase token' });
        }
        
        res.status(500).json({ error: 'Firebase authentication failed' });
    }
});

// Employer Firebase Login/Register
app.post('/api/auth/employer/firebase-login', async (req, res) => {
    try {
        const { idToken, userInfo = {} } = req.body;
        
        if (!idToken) {
            return res.status(400).json({ error: 'Firebase ID token required' });
        }
        
        // Verify the Firebase ID token
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const firebaseUser = decodedToken;
        
        // Find or create user in database (enforce employer role)
        const user = await findOrCreateFirebaseUser(firebaseUser, userInfo, 'employer');
        
        // Generate JWT token
        const token = generateToken(user);
        
        // Remove sensitive data
        const { password, firebase_uid, ...safeUser } = user;
        
        res.json({
            message: 'Employer Firebase authentication successful',
            token,
            user: safeUser,
            authMethod: 'firebase'
        });
        
    } catch (error) {
        console.error('Employer Firebase auth error:', error);
        
        if (error.message.includes('User role mismatch')) {
            return res.status(403).json({ 
                error: 'This account is registered as a job seeker. Please use the Job Seeker Portal.',
                userRole: 'job_seeker'
            });
        }
        
        if (error.code === 'auth/id-token-expired') {
            return res.status(401).json({ error: 'Firebase token expired' });
        } else if (error.code === 'auth/id-token-revoked') {
            return res.status(401).json({ error: 'Firebase token revoked' });
        } else if (error.code === 'auth/invalid-id-token') {
            return res.status(401).json({ error: 'Invalid Firebase token' });
        }
        
        res.status(500).json({ error: 'Firebase authentication failed' });
    }
});

// Job Seeker Traditional Login
app.post('/api/auth/jobseeker/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }

        pool.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
            if (err) return res.status(500).json({ error: 'Database error' });
            if (results.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

            const user = results[0];
            
            // Check if user is a job seeker
            if (user.role !== 'job_seeker') {
                if (user.role === 'employer') {
                    return res.status(403).json({ 
                        error: 'This account is registered as an employer. Please use the Employer Portal.',
                        userRole: 'employer',
                        redirectTo: 'employer-portal'
                    });
                } else {
                    return res.status(403).json({ error: 'Access denied for this account type' });
                }
            }
            
            // Check if user has a password (might be Firebase-only user)
            if (!user.password) {
                return res.status(401).json({ 
                    error: 'Please sign in with Google',
                    requiresGoogleAuth: true 
                });
            }

            const isValid = await bcrypt.compare(password, user.password);
            
            if (!isValid) return res.status(401).json({ error: 'Invalid credentials' });

            const token = generateToken(user);

            const { password: _, firebase_uid, ...userWithoutPassword } = user;
            res.json({ 
                message: 'Job seeker login successful', 
                token, 
                user: userWithoutPassword,
                authMethod: 'traditional'
            });
        });
    } catch (error) {
        console.error('Job seeker login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Employer Traditional Login
app.post('/api/auth/employer/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }

        pool.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
            if (err) return res.status(500).json({ error: 'Database error' });
            if (results.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

            const user = results[0];
            
            // Check if user is an employer or admin
            if (user.role !== 'employer' && user.role !== 'admin') {
                if (user.role === 'job_seeker') {
                    return res.status(403).json({ 
                        error: 'This account is registered as a job seeker. Please use the Job Seeker Portal.',
                        userRole: 'job_seeker',
                        redirectTo: 'jobseeker-portal'
                    });
                } else {
                    return res.status(403).json({ error: 'Access denied for this account type' });
                }
            }
            
            // Check if user has a password (might be Firebase-only user)
            if (!user.password) {
                return res.status(401).json({ 
                    error: 'Please sign in with Google',
                    requiresGoogleAuth: true 
                });
            }

            const isValid = await bcrypt.compare(password, user.password);
            
            if (!isValid) return res.status(401).json({ error: 'Invalid credentials' });

            const token = generateToken(user);

            const { password: _, firebase_uid, ...userWithoutPassword } = user;
            res.json({ 
                message: 'Employer login successful', 
                token, 
                user: userWithoutPassword,
                authMethod: 'traditional'
            });
        });
    } catch (error) {
        console.error('Employer login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Traditional Register (with role specification)
app.post('/api/auth/register', async (req, res) => {
    try {
        const { email, password, firstName, lastName, role = 'job_seeker', phone, company_name } = req.body;
        
        if (!email || !password || !firstName || !lastName) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Validate role
        const allowedRoles = ['job_seeker', 'employer'];
        if (!allowedRoles.includes(role)) {
            return res.status(400).json({ error: 'Invalid role specified' });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ error: 'Invalid email format' });
        }

        // Validate password strength
        if (password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters long' });
        }

        // Check if user exists
        pool.query('SELECT id FROM users WHERE email = ?', [email], async (err, results) => {
            if (err) return res.status(500).json({ error: 'Database error' });
            if (results.length > 0) return res.status(400).json({ error: 'Email already exists' });

            // Hash password and create user
            const hashedPassword = await bcrypt.hash(password, 12);
            const sql = `INSERT INTO users (email, password, first_name, last_name, role, phone, company_name) 
                        VALUES (?, ?, ?, ?, ?, ?, ?)`;
            
            pool.query(sql, [email, hashedPassword, firstName, lastName, role, phone, company_name], (err, result) => {
                if (err) {
                    console.error('Registration error:', err);
                    return res.status(500).json({ error: 'Registration failed' });
                }
                
                const user = { 
                    id: result.insertId, 
                    email, 
                    first_name: firstName, 
                    last_name: lastName, 
                    role,
                    phone,
                    company_name 
                };
                const token = generateToken(user);
                
                res.status(201).json({ 
                    message: `${role === 'job_seeker' ? 'Job seeker' : 'Employer'} registered successfully`, 
                    token, 
                    user,
                    authMethod: 'traditional'
                });
            });
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Backward compatibility - General Login (deprecated)
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }

        pool.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
            if (err) return res.status(500).json({ error: 'Database error' });
            if (results.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

            const user = results[0];
            
            // Check if user has a password (might be Firebase-only user)
            if (!user.password) {
                return res.status(401).json({ 
                    error: 'Please sign in with Google',
                    requiresGoogleAuth: true 
                });
            }

            const isValid = await bcrypt.compare(password, user.password);
            
            if (!isValid) return res.status(401).json({ error: 'Invalid credentials' });

            const token = generateToken(user);

            const { password: _, firebase_uid, ...userWithoutPassword } = user;
            res.json({ 
                message: 'Login successful', 
                token, 
                user: userWithoutPassword,
                authMethod: 'traditional',
                deprecated: true,
                recommendation: `Please use /api/auth/${user.role === 'job_seeker' ? 'jobseeker' : 'employer'}/login for better security`
            });
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// General Firebase Login (deprecated)
app.post('/api/auth/firebase-login', async (req, res) => {
    try {
        const { idToken, userInfo = {} } = req.body;
        
        if (!idToken) {
            return res.status(400).json({ error: 'Firebase ID token required' });
        }
        
        // Verify the Firebase ID token
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const firebaseUser = decodedToken;
        
        // Find or create user in database (default to employer for backward compatibility)
        const user = await findOrCreateFirebaseUser(firebaseUser, userInfo, 'employer');
        
        // Generate JWT token
        const token = generateToken(user);
        
        // Remove sensitive data
        const { password, firebase_uid, ...safeUser } = user;
        
        res.json({
            message: 'Firebase authentication successful',
            token,
            user: safeUser,
            authMethod: 'firebase',
            deprecated: true,
            recommendation: `Please use /api/auth/${user.role === 'job_seeker' ? 'jobseeker' : 'employer'}/firebase-login for better security`
        });
        
    } catch (error) {
        console.error('Firebase auth error:', error);
        
        if (error.code === 'auth/id-token-expired') {
            return res.status(401).json({ error: 'Firebase token expired' });
        } else if (error.code === 'auth/id-token-revoked') {
            return res.status(401).json({ error: 'Firebase token revoked' });
        } else if (error.code === 'auth/invalid-id-token') {
            return res.status(401).json({ error: 'Invalid Firebase token' });
        }
        
        res.status(500).json({ error: 'Firebase authentication failed' });
    }
});

// Get profile
app.get('/api/auth/profile', authenticateToken, (req, res) => {
    pool.query('SELECT * FROM users WHERE id = ?', [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'User not found' });
        
        const { password, firebase_uid, ...user } = results[0];
        res.json(user);
    });
});

// Update profile
app.put('/api/auth/profile', authenticateToken, (req, res) => {
    const { firstName, lastName, phone, company_name } = req.body;
    
    const updates = [];
    const values = [];
    
    if (firstName !== undefined) {
        updates.push('first_name = ?');
        values.push(firstName);
    }
    if (lastName !== undefined) {
        updates.push('last_name = ?');
        values.push(lastName);
    }
    if (phone !== undefined) {
        updates.push('phone = ?');
        values.push(phone);
    }
    if (company_name !== undefined) {
        updates.push('company_name = ?');
        values.push(company_name);
    }
    
    if (updates.length === 0) {
        return res.status(400).json({ error: 'No valid fields to update' });
    }
    
    values.push(req.user.id);
    
    const sql = `UPDATE users SET ${updates.join(', ')} WHERE id = ?`;
    
    pool.query(sql, values, (err) => {
        if (err) return res.status(500).json({ error: 'Update failed' });
        res.json({ message: 'Profile updated successfully' });
    });
});

// Logout (invalidate Firebase session if needed)
app.post('/api/auth/logout', authenticateToken, async (req, res) => {
    try {
        // If user logged in with Firebase, revoke their refresh tokens
        if (req.body.firebase_uid) {
            try {
                await admin.auth().revokeRefreshTokens(req.body.firebase_uid);
            } catch (error) {
                console.warn('Could not revoke Firebase tokens:', error.message);
            }
        }
        
        res.json({ message: 'Logged out successfully' });
    } catch (error) {
        res.json({ message: 'Logged out successfully' }); // Still return success
    }
});

// ==================== JOBS ROUTES ====================

// Get all jobs
app.get('/api/jobs', (req, res) => {
    const { search, location, type, page = 1, limit = 20 } = req.query;
    let sql = 'SELECT * FROM jobs WHERE status = "active"';
    let params = [];
    let conditions = [];

    if (search) {
        conditions.push('(title LIKE ? OR company LIKE ? OR description LIKE ?)');
        params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (location) {
        conditions.push('location LIKE ?');
        params.push(`%${location}%`);
    }
    if (type) {
        conditions.push('type = ?');
        params.push(type);
    }

    if (conditions.length > 0) {
        sql += ' AND ' + conditions.join(' AND ');
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);
    sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    pool.query(sql, params, (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json({ jobs: results });
    });
});

// Get jobs posted by current employer
app.get('/api/jobs/my', authenticateToken, requireRole(['employer', 'admin']), (req, res) => {
    const sql = 'SELECT * FROM jobs WHERE posted_by = ? ORDER BY created_at DESC';
    pool.query(sql, [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json({ jobs: results });
    });
});

// Get single job
app.get('/api/jobs/:id', (req, res) => {
    const sql = 'SELECT * FROM jobs WHERE id = ?';
    pool.query(sql, [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Job not found' });
        res.json(results[0]);
    });
});

// Create job (employers only)
app.post('/api/jobs', authenticateToken, requireRole(['employer', 'admin']), (req, res) => {
    const { title, company, location, type, description, requirements, salary_range, status = 'active' } = req.body;
    
    if (!title || !company || !location || !type || !description) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const sql = `INSERT INTO jobs (title, company, location, type, description, requirements, salary_range, posted_by, status) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;
    
    pool.query(sql, [title, company, location, type, description, requirements, salary_range, req.user.id, status], (err, result) => {
        if (err) {
            console.error('Job creation error:', err);
            return res.status(500).json({ error: 'Failed to create job' });
        }
        res.status(201).json({ message: 'Job created successfully', job_id: result.insertId });
    });
});

// Update job
app.put('/api/jobs/:id', authenticateToken, (req, res) => {
    const { title, company, location, type, description, requirements, salary_range, status } = req.body;
    
    // Check ownership
    pool.query('SELECT posted_by FROM jobs WHERE id = ?', [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Job not found' });
        if (results[0].posted_by !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        const sql = `UPDATE jobs SET title = COALESCE(?, title), company = COALESCE(?, company), 
                     location = COALESCE(?, location), type = COALESCE(?, type), 
                     description = COALESCE(?, description), requirements = COALESCE(?, requirements), 
                     salary_range = COALESCE(?, salary_range), status = COALESCE(?, status) WHERE id = ?`;
        
        pool.query(sql, [title, company, location, type, description, requirements, salary_range, status, req.params.id], (err) => {
            if (err) return res.status(500).json({ error: 'Update failed' });
            res.json({ message: 'Job updated successfully' });
        });
    });
});

// Delete job
app.delete('/api/jobs/:id', authenticateToken, (req, res) => {
    // Check ownership
    pool.query('SELECT posted_by FROM jobs WHERE id = ?', [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Job not found' });
        if (results[0].posted_by !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        pool.query('DELETE FROM jobs WHERE id = ?', [req.params.id], (err) => {
            if (err) return res.status(500).json({ error: 'Delete failed' });
            res.json({ message: 'Job deleted successfully' });
        });
    });
});

// ==================== APPLICATIONS ROUTES ====================

// Apply to job
app.post('/api/applications', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const { jobId, coverLetter } = req.body;
    
    if (!jobId) return res.status(400).json({ error: 'Job ID required' });

    // Check if user completed universal assessment
    pool.query('SELECT assessment_completed FROM users WHERE id = ?', 
        [req.user.id], (err, userResults) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        
        if (userResults.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        if (!userResults[0].assessment_completed) {
            return res.status(400).json({ 
                error: 'Professional Skills Assessment must be completed before applying to jobs',
                requiresAssessment: true,
                assessmentUrl: '/assessment'
            });
        }
        
        // Check if already applied
        pool.query('SELECT id FROM applications WHERE user_id = ? AND job_id = ?', 
            [req.user.id, jobId], (err, existingApp) => {
            if (err) return res.status(500).json({ error: 'Database error' });
            
            if (existingApp.length > 0) {
                return res.status(400).json({ error: 'Already applied to this job' });
            }
            
            // Create application
            const sql = 'INSERT INTO applications (job_id, user_id, cover_letter) VALUES (?, ?, ?)';
            pool.query(sql, [jobId, req.user.id, coverLetter], (err, result) => {
                if (err) return res.status(500).json({ error: 'Application failed' });
                
                res.status(201).json({ 
                    message: 'Application submitted successfully', 
                    application_id: result.insertId 
                });
            });
        });
    });
});

// Get user's applications (includes assessment score)
app.get('/api/applications/my', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const sql = `
        SELECT a.*, j.title, j.company, j.location, j.salary_range,
               u.assessment_score, u.assessment_completed
        FROM applications a 
        JOIN jobs j ON a.job_id = j.id 
        JOIN users u ON a.user_id = u.id
        WHERE a.user_id = ? 
        ORDER BY a.created_at DESC
    `;
    
    pool.query(sql, [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Get received applications (employers - includes universal assessment scores)
app.get('/api/applications/received', authenticateToken, requireRole(['employer', 'admin']), (req, res) => {
    const sql = `
        SELECT a.*, j.title, j.company, 
               u.first_name, u.last_name, u.email, u.phone,
               u.assessment_score, u.assessment_completed, u.assessment_date,
               CASE 
                   WHEN u.assessment_score >= 90 THEN 'Excellent'
                   WHEN u.assessment_score >= 80 THEN 'Very Good'
                   WHEN u.assessment_score >= 70 THEN 'Good'
                   WHEN u.assessment_score >= 60 THEN 'Satisfactory'
                   WHEN u.assessment_score < 60 THEN 'Needs Improvement'
                   ELSE 'Not Assessed'
               END as assessment_level
        FROM applications a 
        JOIN jobs j ON a.job_id = j.id 
        JOIN users u ON a.user_id = u.id 
        WHERE j.posted_by = ? 
        ORDER BY u.assessment_score DESC, a.created_at DESC
    `;
    
    pool.query(sql, [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Update application status
app.put('/api/applications/:id/status', authenticateToken, requireRole(['employer', 'admin']), (req, res) => {
    const { status } = req.body;
    const validStatuses = ['pending', 'reviewed', 'accepted', 'rejected'];
    
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
    }

    const checkSql = `SELECT a.id FROM applications a JOIN jobs j ON a.job_id = j.id 
                      WHERE a.id = ? AND j.posted_by = ?`;
    
    pool.query(checkSql, [req.params.id, req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Application not found' });

        pool.query('UPDATE applications SET status = ? WHERE id = ?', [status, req.params.id], (err) => {
            if (err) return res.status(500).json({ error: 'Update failed' });
            res.json({ message: 'Status updated successfully' });
        });
    });
});

// ==================== SAVED JOBS ROUTES ====================

// Save a job
app.post('/api/jobs/:id/save', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const sql = 'INSERT INTO saved_jobs (job_id, user_id) VALUES (?, ?)';
    pool.query(sql, [req.params.id, req.user.id], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'Job already saved' });
            }
            return res.status(500).json({ error: 'Failed to save job' });
        }
        res.status(201).json({ message: 'Job saved successfully' });
    });
});

// Remove saved job
app.delete('/api/jobs/:id/save', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const sql = 'DELETE FROM saved_jobs WHERE job_id = ? AND user_id = ?';
    pool.query(sql, [req.params.id, req.user.id], (err, result) => {
        if (err) return res.status(500).json({ error: 'Failed to remove saved job' });
        res.json({ message: 'Job removed from saved list' });
    });
});

// Get user's saved jobs
app.get('/api/jobs/saved', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const sql = `SELECT j.*, sj.created_at as saved_at 
                 FROM saved_jobs sj JOIN jobs j ON sj.job_id = j.id 
                 WHERE sj.user_id = ? ORDER BY sj.created_at DESC`;
    
    pool.query(sql, [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json({ jobs: results });
    });
});

// ==================== ASSESSMENT ROUTES ====================

// Check if user can take assessment
app.get('/api/assessment/status', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    pool.query('SELECT assessment_completed, assessment_score, assessment_date FROM users WHERE id = ?', 
        [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        
        const user = results[0];
        
        if (user.assessment_completed) {
            // Get detailed results
            pool.query('SELECT * FROM user_assessments WHERE user_id = ?', 
                [req.user.id], (err, assessmentResults) => {
                if (err) return res.status(500).json({ error: 'Database error' });
                
                return res.json({
                    canTakeAssessment: false,
                    hasCompleted: true,
                    assessment: assessmentResults[0],
                    message: 'Assessment already completed. You can only take it once.'
                });
            });
        } else {
            res.json({
                canTakeAssessment: true,
                hasCompleted: false,
                message: 'You can now take the Professional Skills Assessment.'
            });
        }
    });
});

// Submit assessment results
app.post('/api/assessment/submit', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const { 
        answers, 
        timeTaken, 
        totalQuestions, 
        correctAnswers, 
        totalPoints, 
        maxPossiblePoints, 
        percentageScore, 
        skillBreakdown 
    } = req.body;
    
    // Validate required fields
    if (!answers || !Array.isArray(answers) || 
        typeof totalQuestions !== 'number' || 
        typeof correctAnswers !== 'number' ||
        typeof totalPoints !== 'number' ||
        typeof percentageScore !== 'number' ||
        !skillBreakdown) {
        return res.status(400).json({ error: 'Invalid assessment submission data' });
    }
    
    // Validate data ranges
    if (totalQuestions !== 15 || 
        correctAnswers > totalQuestions || 
        percentageScore < 0 || percentageScore > 100 ||
        maxPossiblePoints !== 150) {
        return res.status(400).json({ error: 'Invalid assessment data ranges' });
    }
    
    // Check if user already completed assessment
    pool.query('SELECT id FROM user_assessments WHERE user_id = ?', 
        [req.user.id], (err, existingAssessment) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        
        if (existingAssessment.length > 0) {
            return res.status(400).json({ error: 'Assessment already completed' });
        }
        
        // Start transaction
        pool.getConnection((err, connection) => {
            if (err) return res.status(500).json({ error: 'Database connection error' });
            
            connection.beginTransaction((err) => {
                if (err) {
                    connection.release();
                    return res.status(500).json({ error: 'Transaction error' });
                }
                
                // Insert into user_assessments table
                const insertAssessmentSql = `
                    INSERT INTO user_assessments 
                    (user_id, total_questions, correct_answers, total_points, max_possible_points, 
                     percentage_score, time_taken_seconds, skill_scores, user_answers) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                `;
                
                connection.query(insertAssessmentSql, [
                    req.user.id, 
                    totalQuestions, 
                    correctAnswers, 
                    totalPoints, 
                    maxPossiblePoints, 
                    percentageScore, 
                    timeTaken, 
                    JSON.stringify(skillBreakdown), 
                    JSON.stringify(answers)
                ], (err, result) => {
                    if (err) {
                        console.error('Error inserting assessment:', err);
                        return connection.rollback(() => {
                            connection.release();
                            res.status(500).json({ error: 'Failed to save assessment results' });
                        });
                    }
                    
                    // Update users table
                    const updateUserSql = `
                        UPDATE users 
                        SET assessment_completed = 1, 
                            assessment_score = ?, 
                            assessment_date = NOW() 
                        WHERE id = ?
                    `;
                    
                    connection.query(updateUserSql, [percentageScore, req.user.id], (err) => {
                        if (err) {
                            console.error('Error updating user:', err);
                            return connection.rollback(() => {
                                connection.release();
                                res.status(500).json({ error: 'Failed to update user assessment status' });
                            });
                        }
                        
                        // Commit the transaction
                        connection.commit((err) => {
                            if (err) {
                                console.error('Error committing transaction:', err);
                                return connection.rollback(() => {
                                    connection.release();
                                    res.status(500).json({ error: 'Transaction commit failed' });
                                });
                            }
                            
                            connection.release();
                            
                            res.json({
                                success: true,
                                message: 'Professional Skills Assessment completed successfully',
                                assessmentId: result.insertId,
                                score: {
                                    percentage: percentageScore,
                                    correctAnswers: correctAnswers,
                                    totalQuestions: totalQuestions,
                                    points: totalPoints,
                                    maxPoints: maxPossiblePoints,
                                    skillBreakdown: skillBreakdown
                                },
                                timeTaken: timeTaken
                            });
                        });
                    });
                });
            });
        });
    });
});

// Get user's assessment result
app.get('/api/assessment/my-result', authenticateToken, requireRole(['job_seeker']), (req, res) => {
    const sql = `
        SELECT ua.*, u.first_name, u.last_name 
        FROM user_assessments ua
        JOIN users u ON ua.user_id = u.id
        WHERE ua.user_id = ?
    `;
    
    pool.query(sql, [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        
        if (results.length === 0) {
            return res.status(404).json({ 
                error: 'Assessment not completed',
                hasCompleted: false 
            });
        }
        
        const result = results[0];
        result.hasCompleted = true;
        res.json(result);
    });
});

// ==================== UTILITY ROUTES ====================

// API info
app.get('/api', (req, res) => {
    res.json({
        message: 'Job Seeker API with Separated Authentication',
        version: '2.2.0',
        firebase: 'enabled',
        endpoints: {
            auth: {
                jobseeker: [
                    'POST /api/auth/jobseeker/login - Job seeker traditional login',
                    'POST /api/auth/jobseeker/firebase-login - Job seeker Firebase authentication'
                ],
                employer: [
                    'POST /api/auth/employer/login - Employer traditional login', 
                    'POST /api/auth/employer/firebase-login - Employer Firebase authentication'
                ],
                general: [
                    'POST /api/auth/register - Registration (specify role)',
                    'GET /api/auth/profile - Get user profile',
                    'PUT /api/auth/profile - Update profile',
                    'POST /api/auth/logout - Logout'
                ],
                deprecated: [
                    'POST /api/auth/login - General login (deprecated)',
                    'POST /api/auth/firebase-login - General Firebase login (deprecated)'
                ]
            },
            jobs: [
                'GET /api/jobs - Get all jobs',
                'GET /api/jobs/my - Get my posted jobs',
                'GET /api/jobs/:id - Get single job',
                'POST /api/jobs - Create job',
                'PUT /api/jobs/:id - Update job',
                'DELETE /api/jobs/:id - Delete job'
            ],
            applications: [
                'POST /api/applications - Apply to job',
                'GET /api/applications/my - Get my applications',
                'GET /api/applications/received - Get received applications',
                'PUT /api/applications/:id/status - Update application status'
            ],
            saved: [
                'POST /api/jobs/:id/save - Save job',
                'DELETE /api/jobs/:id/save - Remove saved job',
                'GET /api/jobs/saved - Get saved jobs'
            ],
            assessment: [
                'GET /api/assessment/status - Check assessment status',
                'POST /api/assessment/submit - Submit assessment',
                'GET /api/assessment/my-result - Get assessment result'
            ]
        }
    });
});

// Health check
app.get('/api/health', (req, res) => {
    pool.query('SELECT 1', (err) => {
        if (err) return res.status(503).json({ status: 'unhealthy', database: 'disconnected' });
        res.json({ 
            status: 'healthy', 
            database: 'connected',
            firebase: admin.apps.length > 0 ? 'initialized' : 'not initialized',
            timestamp: new Date().toISOString()
        });
    });
});

// Root route
app.get('/', (req, res) => {
    res.json({
        message: '🚀 Job Seeker API Server with Separated Authentication',
        version: '2.2.0',
        status: 'running',
        features: ['Separated Auth', 'Role-specific Endpoints', 'Firebase Auth', 'Google OAuth', 'Role-based Access'],
        description: 'A complete job board API with separated authentication for employers and job seekers',
        endpoints: {
            info: 'GET /api - API information',
            health: 'GET /api/health - Health check'
        },
        firebase: {
            status: admin.apps.length > 0 ? 'initialized' : 'not initialized',
            projectId: 'jobseeker-655c1'
        },
        documentation: 'Visit /api for detailed endpoint information'
    });
});

// Error handling
app.use((err, req, res, next) => {
    console.error('Global error handler:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    pool.end(() => {
        console.log('Database connection pool closed');
        process.exit(0);
    });
});

// Start server
app.listen(port, () => {
    console.log(`🚀 Job Seeker API running on port ${port}`);
    console.log(`📋 Jobs: http://localhost:${port}/api/jobs`);
    console.log(`🔐 Job Seeker Auth: http://localhost:${port}/api/auth/jobseeker/*`);
    console.log(`🏢 Employer Auth: http://localhost:${port}/api/auth/employer/*`);
    console.log(`🔥 Firebase: ${admin.apps.length > 0 ? 'Enabled' : 'Disabled'}`);
    console.log(`🌐 API Info: http://localhost:${port}/api`);
});

module.exports = app;