const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const port = 5000;

const JWT_SECRET = 'your_very_secret_key_here';

app.use(cors());
app.use(bodyParser.json());

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Startsy',
  password: 'postgres',
  port: 5432,
});

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    console.log('No token provided');
    return res.status(401).json({ message: 'Authorization token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      console.log('Token verification failed:', err.message);
      return res.status(403).json({ 
        message: 'Invalid or expired token',
        error: err.message 
      });
    }
    req.user = user;
    next();
  });
};

module.exports = authenticateToken;

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
    
    await pool.query(
      'INSERT INTO user_settings (user_id, dark_mode) VALUES ($1, $2)',
      [user.id, false]
    );


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

    console.log('User Data:', user);
    const token = jwt.sign(
      { 
        userId: user.id, 
        username: user.username, 
        role: user.role 
      }, 
      JWT_SECRET,
      { expiresIn: '6h' }
    );

    console.log('Generated Token:', token);

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


app.post('/startups', authenticateToken, async (req, res) => {
  const { name, description, required_skills, contact_info, color } = req.body;
  const founderId = req.user.userId;

  try {
    const result = await pool.query(`
      INSERT INTO startups (name, description, required_skills, contact_info, founder_id, color)
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [name, description, required_skills, contact_info, founderId, color || '#ffffff']
    );

    await pool.query('INSERT INTO startup_members (startup_id, user_id) VALUES ($1, $2)', 
      [result.rows[0].id, founderId]);

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating startup:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.get('/api/skills', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM skills');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('Error fetching skills');
  }
});

app.post('/startups/:id/join', authenticateToken, async (req, res) => {
  const startupId = req.params.id;
  const userId = req.user.userId;

  try {
    const existingMember = await pool.query(
      'SELECT * FROM startup_members WHERE startup_id = $1 AND user_id = $2',
      [startupId, userId]
    );

    if (existingMember.rows.length > 0) {
      return res.status(400).json({ message: 'Already a member of this startup' });
    }

    await pool.query(
      'INSERT INTO startup_members (startup_id, user_id) VALUES ($1, $2)',
      [startupId, userId]
    );

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

app.get('/me', authenticateToken, async (req, res) => {
  try {
    const user = await pool.query('SELECT id, username, role, full_name FROM users WHERE id = $1', [req.user.userId]);
    if (user.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user.rows[0]);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

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

app.delete('/startups/:id', authenticateToken, async (req, res) => {
  try {
    const startup = await pool.query('SELECT founder_id FROM startups WHERE id = $1', [req.params.id]);
    if (startup.rows.length === 0) {
      return res.status(404).json({ message: 'Startup not found' });
    }

    if (Number(startup.rows[0].founder_id) !== Number(req.user.userId)) {
      return res.status(403).json({ message: 'Only the founder can delete this startup' });
    }

    await pool.query('DELETE FROM startup_members WHERE startup_id = $1', [req.params.id]);
    await pool.query('DELETE FROM startups WHERE id = $1', [req.params.id]);
    
    res.json({ message: 'Startup deleted successfully' });
  } catch (err) {
    console.error('Delete error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

app.get('/api/user/settings', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT dark_mode FROM user_settings WHERE user_id = $1',
      [req.user.userId]
    );
    
    res.json({ 
      dark_mode: result.rows[0]?.dark_mode ?? false,
      user_id: req.user.userId
    });
  } catch (err) {
    console.error('Settings fetch error:', err);
    res.status(500).json({ 
      message: 'Failed to load settings',
      error: err.message 
    });
  }
});

app.post('/api/user/settings', authenticateToken, async (req, res) => {
  const { dark_mode } = req.body;
  
  if (typeof dark_mode !== 'boolean') {
    return res.status(400).json({ message: 'Invalid dark_mode value' });
  }

  try {
    await pool.query(`
      INSERT INTO user_settings (user_id, dark_mode, updated_at)
      VALUES ($1, $2, NOW())
      ON CONFLICT (user_id) 
      DO UPDATE SET 
        dark_mode = EXCLUDED.dark_mode,
        updated_at = NOW()
    `, [req.user.userId, dark_mode]);
    
    res.json({ 
      success: true,
      message: 'Settings updated',
      dark_mode
    });
  } catch (err) {
    console.error('Settings save error:', err);
    res.status(500).json({ 
      message: 'Failed to save settings',
      error: err.message 
    });
  }
});

app.post('/api/user/change-password', authenticateToken, async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Both passwords are required' });
  }

  try {
    const user = await pool.query(
      'SELECT password_hash FROM users WHERE id = $1', 
      [req.user.userId]
    );
    
    const isValid = await bcrypt.compare(currentPassword, user.rows[0].password_hash);
    if (!isValid) {
      return res.status(401).json({ message: 'Current password is incorrect' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2',
      [hashedPassword, req.user.userId]
    );

    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    console.error('Password change error:', err);
    res.status(500).json({ message: 'Error changing password' });
  }
});

app.listen(port, () => {
  console.log(`✅ Server running on port ${port}`);
});
