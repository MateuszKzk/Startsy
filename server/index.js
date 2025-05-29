const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
require('dotenv').config();



const app = express();
const port = 5000;

app.use(cookieParser());

const corsOptions = {
  origin: 'http://localhost:9000',
  credentials: true,
  allowedHeaders: ['Content-Type', 'Authorization'],
  methods: ['GET', 'POST', 'OPTIONS', 'DELETE'],
  exposedHeaders: ['set-cookie']
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions)); // Für Preflight-Requests

app.use(bodyParser.json());

const JWT_SECRET = process.env.JWT_SECRET;

const pool = new Pool({
  user: process.env.DATABASE_USER,
  host: process.env.DATABASE_HOST,
  database: process.env.DATABASE_NAME,
  password: process.env.DATABASE_PASSWORD,
  port: process.env.DATABASE_PORT,
});

// Verbessertes authenticateToken Middleware
const authenticateToken = (req, res, next) => {
  console.log('Cookies:', req.cookies); // Debug cookies
  console.log('Headers:', req.headers); // Debug headers
  
  // 1. Check cookie first
  let token = req.cookies?.token;
  
  // 2. Fallback to Authorization header
  if (!token && req.headers.authorization) {
    const authHeader = req.headers.authorization;
    console.log('Auth header:', authHeader); // Debug auth header
    token = authHeader.split(' ')[1];
  }

  if (!token) {
    console.log('No token found');
    return res.status(401).json({ message: 'Authentication required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      console.log('Token verification failed:', err.message); // Debug token error
      return res.status(403).json({ 
        message: 'Invalid token',
        error: err.message 
      });
    }
    console.log('Authenticated user:', user); // Debug user
    req.user = user;
    next();
  });
};

// Add to your server.js
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

const activeConnections = new Map();

wss.on('connection', (ws, req) => {
  // Extract token from query params or headers
  const token = req.url.split('token=')[1];
  
  if (!token) {
    ws.close();
    return;
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      ws.close();
      return;
    }

    // Store connection with user ID
    activeConnections.set(user.userId, ws);

    ws.on('message', (message) => {
      // Handle incoming messages
      const { conversationId, content, recipientId } = JSON.parse(message);
      
      // Broadcast to recipient if online
      if (activeConnections.has(recipientId)) {
        activeConnections.get(recipientId).send(JSON.stringify({
          type: 'new_message',
          conversationId,
          content
        }));
      }
    });

    ws.on('close', () => {
      activeConnections.delete(user.userId);
    });
  });
});

app.options('*', cors());

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

    // HTTP-Only Cookie setzen
    res.cookie('token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 6 * 60 * 60 * 1000, // 6 Stunden
      domain: 'localhost'
    });

    res.json({ 
      success: true,
      user: {
        id: user.id,
        username: user.username
      }

    });

  } catch (error) {
    console.log('Login error:', error);
    res.status(401).json({ 
      success: false,
      message: error.message 
    });
  }
});

app.post('/startups', authenticateToken, async (req, res) => {
  console.log('Received startup data:', req.body); // Add this line
  const { name, description, required_skills, contacts, color } = req.body;
  const founderId = req.user.userId;

  try {
    console.log('Values being inserted:', [name, description, required_skills, contacts, founderId, color || '#ffffff']); // Add this line
    
    const result = await pool.query(`
      INSERT INTO startups (name, description, required_skills, contacts, founder_id, color)
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [name, description, required_skills, contacts, founderId, color || '#ffffff']
    );

    await pool.query(
      'INSERT INTO startup_members (startup_id, user_id) VALUES ($1, $2)',
      [result.rows[0].id, founderId]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating startup:', err);
    res.status(500).json({ 
      message: 'Server error', 
      error: err.message,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
  }
});

app.get('/api/skills', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM skills');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('Error fetching skills');
    console.err(err.message);
  }
});

// Neue Route für gefilterte Startups
app.get('/startups/filtered', async (req, res) => {
  try {
    const { search, category } = req.query;

    // Basis-Query ohne GROUP BY
    let query = `
      SELECT s.*, u.username as founder_username,
      (SELECT COUNT(*) FROM startup_members sm WHERE sm.startup_id = s.id) as members_count
      FROM startups s
      LEFT JOIN users u ON s.founder_id = u.id
    `;

    const params = [];
    const conditions = [];

    if (category) {
      query += ` LEFT JOIN skills sk ON sk.id = ANY(string_to_array(s.required_skills, ',')::int[])`;
      conditions.push(`sk.category = $${params.length + 1}`);
      params.push(category);
    }

    if (search) {
      conditions.push(`
        (s.name ILIKE $${params.length + 1} OR 
         s.description ILIKE $${params.length + 1} OR
         EXISTS (
           SELECT 1 FROM skills sk 
           WHERE sk.id = ANY(string_to_array(s.required_skills, ',')::int[])
           AND sk.name ILIKE $${params.length + 1}
         )
        )
      `);
      params.push(`%${search}%`);
    }

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }

    query += ` ORDER BY s.created_at DESC`;

    console.log('Final Query:', query); // Debug output
    const result = await pool.query(query, params);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ 
      message: 'Internal server error',
      error: err.message,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
  }
});


// Angepasster /api/user/profile Endpoint
app.get('/api/user/profile', authenticateToken, async (req, res) => {
  try {
    // Benutzerdaten abrufen (ohne email und avatar)
    const userQuery = await pool.query(`
      SELECT 
        u.id, u.username, u.full_name, u.role
      FROM users u
      WHERE u.id = $1
    `, [req.user.userId]);
    
    if (userQuery.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userQuery.rows[0];

    // Dark Mode-Einstellung abrufen
    const settingsQuery = await pool.query(`
      SELECT dark_mode FROM user_settings WHERE user_id = $1
    `, [req.user.userId]);
    
    // Startup-Statistiken
    const statsQuery = await pool.query(`
      SELECT 
        COUNT(s.id) as startups_count,
        COALESCE(SUM((SELECT COUNT(*) FROM startup_members WHERE startup_id = s.id)), 0) as total_members
      FROM startups s
      WHERE s.founder_id = $1
    `, [req.user.userId]);

    // Startups des Benutzers
    const startupsQuery = await pool.query(`
      SELECT 
        s.id, s.name, s.description, 
        s.created_at,
        (SELECT COUNT(*) FROM startup_members WHERE startup_id = s.id) as members_count
      FROM startups s
      WHERE s.founder_id = $1
      ORDER BY s.created_at DESC
    `, [req.user.userId]);

    res.json({
      user: {
        ...user,
        dark_mode: settingsQuery.rows[0]?.dark_mode || false
      },
      stats: {
        startups: statsQuery.rows[0].startups_count,
        members: statsQuery.rows[0].total_members
      },
      startups: startupsQuery.rows
    });

  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ error: 'Failed to load profile data' });
  }
});

app.get('/api/user/skills', authenticateToken, async (req, res) => {
  try {
    const skills = await pool.query(`
      SELECT s.id, s.name, us.level 
      FROM user_skills us
      JOIN skills s ON us.skill_id = s.id
      WHERE us.user_id = $1
    `, [req.user.userId]);
    
    res.json(skills.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
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
    console.error(err.message);
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

// Fügen Sie diesen Endpoint hinzu
app.get('/api/me', authenticateToken, async (req, res) => {
  try {
    const user = await pool.query(
      'SELECT id, username, role, full_name FROM users WHERE id = $1', 
      [req.user.userId]
    );
    
    if (user.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json({ user: user.rows[0] });
  } catch (err) {
    console.error('Error fetching user:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

app.post('/logout', (req, res) => {
  res.clearCookie('token', {
    domain: 'localhost',
    path: '/'
  });
  res.json({ message: 'Logged out successfully' });
});

// Get or create conversation between two users
app.post('/api/conversations', authenticateToken, async (req, res) => {
  const { participantId } = req.body;
  const userId = req.user.userId;

  // Input validation
  if (!participantId) {
    return res.status(400).json({ 
      message: "Participant ID is required" 
    });
  }

  if (userId === participantId) {
    return res.status(400).json({ 
      message: "Cannot create conversation with yourself" 
    });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Verify participant exists
    const participantExists = await client.query(
      'SELECT id FROM users WHERE id = $1', 
      [participantId]
    );
    
    if (participantExists.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ 
        message: "Participant not found" 
      });
    }

    // Check if conversation already exists (improved query)
    const existingConversation = await client.query(`
      SELECT c.id 
      FROM conversations c
      WHERE EXISTS (
        SELECT 1 FROM conversation_participants 
        WHERE conversation_id = c.id AND user_id = $1
      )
      AND EXISTS (
        SELECT 1 FROM conversation_participants 
        WHERE conversation_id = c.id AND user_id = $2
      )
      LIMIT 1
    `, [userId, participantId]);

    if (existingConversation.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.json({
        conversationId: existingConversation.rows[0].id,
        isNew: false
      });
    }

    // Create new conversation
    const conversation = await client.query(
      'INSERT INTO conversations DEFAULT VALUES RETURNING id'
    );
    const conversationId = conversation.rows[0].id;

    // Add participants (order doesn't matter)
    await client.query(
      'INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)',
      [conversationId, userId, participantId]
    );

    await client.query('COMMIT');
    
    res.status(201).json({
      conversationId,
      isNew: true
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Conversation creation error:', err);
    res.status(500).json({ 
      message: 'Failed to create conversation',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  } finally {
    client.release();
  }
});

// Get messages for a conversation (improved with proper sender identification)
app.get('/api/conversations/:id/messages', authenticateToken, async (req, res) => {
  const conversationId = req.params.id;
  const userId = req.user.userId;

  try {
    // Verify user is part of conversation
    const isParticipant = await pool.query(
      'SELECT 1 FROM conversation_participants WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (isParticipant.rows.length === 0) {
      return res.status(403).json({ message: 'Not part of this conversation' });
    }

    // Get messages with proper sender identification
    const messages = await pool.query(`
      SELECT 
        m.id,
        m.content,
        m.sent_at,
        m.sender_id,
        m.read_at,
        u.username as sender_username,
        u.full_name as sender_name,
        (m.sender_id = $2) as is_sender
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.sent_at ASC
    `, [conversationId, userId]);

    // Mark messages as read (only if they're not sent by current user)
    await pool.query(`
      UPDATE messages 
      SET read_at = NOW() 
      WHERE conversation_id = $1 
      AND sender_id != $2 
      AND read_at IS NULL
    `, [conversationId, userId]);

    res.json(messages.rows);
  } catch (err) {
    console.error('Get messages error:', err);
    res.status(500).json({ 
      message: 'Server error', 
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
});

// Send a message (with improved response)
app.post('/api/conversations/:id/messages', authenticateToken, async (req, res) => {
  const conversationId = req.params.id;
  const { content } = req.body;
  const userId = req.user.userId;

  if (!content || content.trim() === '') {
    return res.status(400).json({ message: 'Message content is required' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Verify user is part of conversation
    const isParticipant = await client.query(
      'SELECT 1 FROM conversation_participants WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (isParticipant.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({ message: 'Not part of this conversation' });
    }

    // Insert message
    const message = await client.query(`
      INSERT INTO messages (conversation_id, sender_id, content)
      VALUES ($1, $2, $3)
      RETURNING id, content, sent_at, sender_id, read_at
    `, [conversationId, userId, content.trim()]);

    // Update conversation timestamp
    await client.query(
      'UPDATE conversations SET updated_at = NOW() WHERE id = $1',
      [conversationId]
    );

    await client.query('COMMIT');
    
    // Include sender information in response
    const senderInfo = await pool.query(
      'SELECT username, full_name FROM users WHERE id = $1',
      [userId]
    );
    
   res.status(201).json({
  ...message.rows[0],
  sender_username: senderInfo.rows[0].username,
  sender_name: senderInfo.rows[0].full_name,
  is_sender: true,
  sender_id: userId // Jawnie ustaw sender_id
});

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Send message error:', err);
    res.status(500).json({ 
      message: 'Server error',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  } finally {
    client.release();
  }
});

// Get conversation participant info (improved)
app.get('/api/conversations/:id/participant', authenticateToken, async (req, res) => {
  const conversationId = req.params.id;
  const userId = req.user.userId;

  try {
    const participant = await pool.query(`
      SELECT 
        u.id, 
        u.username, 
        u.full_name,
        EXISTS (
          SELECT 1 FROM user_connections 
          WHERE (user_id = $2 AND connection_id = u.id)
          OR (user_id = u.id AND connection_id = $2)
        ) as is_connected
      FROM conversation_participants cp
      JOIN users u ON cp.user_id = u.id
      WHERE cp.conversation_id = $1 AND cp.user_id != $2
    `, [conversationId, userId]);

    if (participant.rows.length === 0) {
      return res.status(404).json({ message: 'Participant not found' });
    }

    res.json(participant.rows[0]);
  } catch (err) {
    console.error('Get participant error:', err);
    res.status(500).json({ 
      message: 'Server error',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
});

// Get all conversations for current user
app.get('/api/conversations', authenticateToken, async (req, res) => {
  const userId = req.user.userId;

  try {
    const conversations = await pool.query(`
      SELECT 
        c.id,
        c.updated_at,
        u.id as participant_id,
        u.username as participant_username,
        u.full_name as participant_name,
        (SELECT content FROM messages WHERE conversation_id = c.id ORDER BY sent_at DESC LIMIT 1) as last_message,
        (SELECT sent_at FROM messages WHERE conversation_id = c.id ORDER BY sent_at DESC LIMIT 1) as last_message_time,
        (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND sender_id != $1 AND read_at IS NULL) as unread_count
      FROM conversations c
      JOIN conversation_participants cp ON c.id = cp.conversation_id
      JOIN users u ON cp.user_id = u.id
      WHERE c.id IN (
        SELECT conversation_id FROM conversation_participants WHERE user_id = $1
      ) AND u.id != $1
      ORDER BY last_message_time DESC NULLS LAST
    `, [userId]);

    res.json(conversations.rows);
  } catch (err) {
    console.error('Get conversations error:', err);
    res.status(500).json({ 
      message: 'Server error', 
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
});

app.listen(port, () => {
  console.log(`✅ Server running on port ${port}`);
});
