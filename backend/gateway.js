const http = require('http');
const httpProxy = require('http-proxy');

// Create a proxy server
const proxy = httpProxy.createProxyServer({});

// Config for your two backends
const AUTH_URL = 'http://localhost:5000';
const SERVICE_URL = 'http://localhost:3000';

const server = http.createServer((req, res) => {
    // 1. All Auth requests go to Port 5000
    if (req.url.startsWith('/api/auth')) {
        proxy.web(req, res, { target: AUTH_URL });
    }
    // 2. All other requests (appointments, analyze, chatbot) go to Port 3000
    else {
        proxy.web(req, res, { target: SERVICE_URL });
    }
});

// Error handling to prevent crashes
proxy.on('error', (err, req, res) => {
    console.error('Proxy Error:', err);
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Gateway Error: Is your backend running?');
});

const PORT = 8000;
console.log(`========================================`);
console.log(`🚀 UNIFIED GATEWAY RUNNING ON PORT ${PORT}`);
console.log(`   Routing /api/auth -> ${AUTH_URL}`);
console.log(`   Routing everything else -> ${SERVICE_URL}`);
console.log(`========================================`);

server.listen(PORT);
