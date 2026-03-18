let http = require('http');
const PORT = process.env.PORT || 3000;
const server = http.createServer(function (req, res) {
  if (req.url == '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', uptime: process.uptime() }));
    return;
  }
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('Hello World');
});

process.on('SIGTERM', () => {
  server.close(() => {
    console.log('Server closed gracefully');
    process.exit(0);
  });
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
