const express = require('express');
const { spawn } = require('child_process');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Status endpoint
app.get('/status', (req, res) => {
  res.status(200).json({
    service: 'WildDuck Email Suite',
    version: '1.0.0',
    hostname: process.env.HOSTNAME || process.env.RAILWAY_PUBLIC_DOMAIN,
    domain: process.env.MAILDOMAIN || process.env.RAILWAY_PUBLIC_DOMAIN,
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>WildDuck Email Suite</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
          .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          h1 { color: #333; border-bottom: 2px solid #007acc; padding-bottom: 10px; }
          .status { background: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
          .info { background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
          .service { margin: 10px 0; padding: 10px; background: #f8f9fa; border-left: 4px solid #007acc; }
          a { color: #007acc; text-decoration: none; }
          a:hover { text-decoration: underline; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🦆 WildDuck Email Suite</h1>
          
          <div class="status">
            <strong>✅ Service Status:</strong> Running on Railway
          </div>
          
          <div class="info">
            <strong>🌐 Domain:</strong> ${process.env.MAILDOMAIN || process.env.RAILWAY_PUBLIC_DOMAIN || 'Not configured'}<br>
            <strong>🏠 Hostname:</strong> ${process.env.HOSTNAME || process.env.RAILWAY_PUBLIC_DOMAIN || 'Not configured'}<br>
            <strong>🔧 Environment:</strong> ${process.env.NODE_ENV || 'development'}
          </div>
          
          <h2>📧 Email Services</h2>
          
          <div class="service">
            <strong>IMAP Server:</strong> Port 143 (993 for SSL)<br>
            <em>For reading emails</em>
          </div>
          
          <div class="service">
            <strong>POP3 Server:</strong> Port 110 (995 for SSL)<br>
            <em>For downloading emails</em>
          </div>
          
          <div class="service">
            <strong>SMTP Server:</strong> Port 25, 587<br>
            <em>For sending emails</em>
          </div>
          
          <div class="service">
            <strong>Webmail Interface:</strong> <a href="http://localhost:3000" target="_blank">Port 3000</a><br>
            <em>Web-based email client</em>
          </div>
          
          <h2>🔗 API Endpoints</h2>
          <ul>
            <li><a href="/health">/health</a> - Health check</li>
            <li><a href="/status">/status</a> - Service status</li>
          </ul>
          
          <div class="info">
            <strong>📚 Documentation:</strong> <a href="https://github.com/zone-eu/wildduck-dockerized" target="_blank">GitHub Repository</a>
          </div>
        </div>
      </body>
    </html>
  `);
});

// Start the HTTP server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 WildDuck Email Suite HTTP server running on port ${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🏠 Hostname: ${process.env.HOSTNAME || process.env.RAILWAY_PUBLIC_DOMAIN || 'localhost'}`);
  console.log(`📧 Mail Domain: ${process.env.MAILDOMAIN || process.env.RAILWAY_PUBLIC_DOMAIN || 'localhost'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🛑 Received SIGINT, shutting down gracefully');
  process.exit(0);
});