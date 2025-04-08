const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const port = 5000;

// JWT Secret Key (in production use environment variable)
const JWT_SECRET = 'your_very_secret_key_here';

// Middlewares
app.use(cors());
app.use(bodyParser.json());

// PostgreSQL-Datenbankverbindung
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Startsy',
  password: 'postgres',
  port: 5432,
});

// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).json({ message: 'Missing token' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid token' });
    req.user = user;
    next();
  });
};

module.exports = authenticateToken;

// Benutzerregistrierung
app.post('/register', async (req, res) => {
  const { username, password, role, full_name } = req.body;

  try {
    const userExists = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO users (username, password_hash, role, full_name) VALUES ($1, $2, $3, $4) RETURNING id, username, role, full_name',
      [username, hashedPassword, role, full_name]
    );

    const user = result.rows[0];
    const token = jwt.sign(
      { userId: user.id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: '6h' }
    );

    res.status(201).json({
      message: 'Registration successful',
      token,
      user
    });

  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Benutzerlogin
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Username not found' });
    }

    const user = result.rows[0];
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      return res.status(401).json({ message: 'Incorrect password' });
    }

    // JWT Token erstellen
    const token = jwt.sign(
      { 
        userId: user.id, 
        username: user.username, 
        role: user.role 
      }, 
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        role: user.role
      }
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Startup erstellen (geschützt mit JWT)
app.post('/startups', authenticateToken, async (req, res) => {
  const { name, description, required_skills, contact_info, color } = req.body;
  const founderId = req.user.userId;  // Aus dem JWT Token

  try {
    const result = await pool.query(`
      INSERT INTO startups (name, description, required_skills, contact_info, founder_id, color)
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [name, description, required_skills, contact_info, founderId, color || '#ffffff']
    );

    // Gründer automatisch als Mitglied hinzufügen
    await pool.query('INSERT INTO startup_members (startup_id, user_id) VALUES ($1, $2)', 
      [result.rows[0].id, founderId]);

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating startup:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Skills abrufen
app.get('/api/skills', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM skills');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('Error fetching skills');
  }
});

// Startup beitreten
// Startup beitreten (mit JWT Authentifizierung)
app.post('/startups/:id/join', authenticateToken, async (req, res) => {
  const startupId = req.params.id;
  const userId = req.user.userId; // Aus dem JWT Token

  try {
    // Überprüfen, ob der Benutzer bereits Mitglied ist
    const existingMember = await pool.query(
      'SELECT * FROM startup_members WHERE startup_id = $1 AND user_id = $2',
      [startupId, userId]
    );

    if (existingMember.rows.length > 0) {
      return res.status(400).json({ message: 'Already a member of this startup' });
    }

    // Benutzer als Mitglied hinzufügen
    await pool.query(
      'INSERT INTO startup_members (startup_id, user_id) VALUES ($1, $2)',
      [startupId, userId]
    );

    // Aktualisierte Mitgliederzahl abrufen
    const membersCount = await pool.query(
      'SELECT COUNT(*) FROM startup_members WHERE startup_id = $1',
      [startupId]
    );

    res.status(200).json({
      message: 'Successfully joined startup',
      members_count: parseInt(membersCount.rows[0].count)
    });
  } catch (err) {
    console.error('Error joining startup:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Benutzers Startups abrufen
app.get('/users/:id/startups', authenticateToken, async (req, res) => {
  const userId = req.params.id;

  try {
    const result = await pool.query(`
      SELECT s.*, COUNT(sm.user_id) as members_count
      FROM startups s
      LEFT JOIN startup_members sm ON s.id = sm.startup_id
      WHERE s.founder_id = $1
      GROUP BY s.id
      ORDER BY s.created_at DESC
    `, [userId]);

    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching user startups:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Startups abrufen (öffentlich zugänglich)
app.get('/startups', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT s.*, COUNT(sm.user_id) as members_count, u.username as founder_username
      FROM startups s
      LEFT JOIN startup_members sm ON s.id = sm.startup_id
      LEFT JOIN users u ON s.founder_id = u.id
      GROUP BY s.id, u.username
      ORDER BY s.created_at DESC
    `);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching startups:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Startup löschen (nur Gründer oder Admin)
app.delete('/startups/:id', authenticateToken, async (req, res) => {
  const startupId = req.params.id;
  const userId = req.user.userId;
  const userRole = req.user.role;

  try {
    // Erst prüfen ob das Startup existiert
    const startup = await pool.query('SELECT * FROM startups WHERE id = $1', [startupId]);
    
    if (startup.rows.length === 0) {
      return res.status(404).json({ message: 'Startup not found' });
    }

    // Berechtigung prüfen (nur Gründer oder Admin darf löschen)
    if (startup.rows[0].founder_id !== userId && userRole !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this startup' });
    }

    // Zuerst die Mitglieder-Beziehungen löschen
    await pool.query('DELETE FROM startup_members WHERE startup_id = $1', [startupId]);
    
    // Dann das Startup selbst löschen
    await pool.query('DELETE FROM startups WHERE id = $1', [startupId]);
    
    res.status(200).json({ message: 'Startup deleted successfully' });
  } catch (err) {
    console.error('Error deleting startup:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.listen(port, () => {
  console.log(`✅ Server running on port ${port}`);
});
