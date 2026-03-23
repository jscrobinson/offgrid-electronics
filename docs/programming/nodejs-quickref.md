# Node.js Quick Reference

Node.js runs JavaScript outside the browser, on servers and local machines. It uses an event-driven, non-blocking I/O model. This reference covers Node.js 18+ LTS.

---

## npm and npx

### npm (Node Package Manager)

```bash
# Initialize a project
npm init                # interactive
npm init -y             # accept all defaults

# Install packages
npm install express           # local dependency (saved to package.json)
npm install -D nodemon        # dev dependency (--save-dev)
npm install -g npm-check      # global install

# Other commands
npm list                      # show installed packages
npm list --depth=0            # top-level only
npm outdated                  # check for updates
npm update                    # update within semver range
npm uninstall express         # remove package
npm cache clean --force       # clear cache
npm audit                     # check for vulnerabilities
npm audit fix                 # auto-fix vulnerabilities

# Offline install (from a local cache)
npm install --offline --cache ./npm-cache/

# Create a tarball cache for offline use
npm pack express              # creates express-4.18.2.tgz
```

### npx (Execute packages)

```bash
npx create-react-app myapp   # run without installing globally
npx http-server .             # quick static file server
npx nodemon app.js            # run from local or remote
```

### package.json Key Fields

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "build": "tsc"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

Semver ranges: `^4.18.0` = >=4.18.0 <5.0.0, `~4.18.0` = >=4.18.0 <4.19.0, `4.18.0` = exact

### npm Scripts

```bash
npm start                # runs "start" script
npm test                 # runs "test" script
npm run dev              # runs custom "dev" script
npm run build            # runs custom "build" script
```

---

## CommonJS vs ES Modules

### CommonJS (CJS) — Traditional Node.js

```javascript
// Exporting
// math.js
function add(a, b) { return a + b; }
function multiply(a, b) { return a * b; }
module.exports = { add, multiply };
// or: module.exports.add = add;
// or: exports.add = add;  (shorthand, don't reassign exports itself)

// Importing
const { add, multiply } = require('./math');
const fs = require('fs');
const express = require('express');
```

### ES Modules (ESM) — Modern (recommended)

Enable by adding `"type": "module"` to package.json, or use `.mjs` extension.

```javascript
// Exporting
// math.js
export function add(a, b) { return a + b; }
export function multiply(a, b) { return a * b; }
export default class Calculator { /* ... */ }

// Importing
import { add, multiply } from './math.js';  // note: .js extension required
import Calculator from './math.js';          // default import
import * as math from './math.js';           // namespace import
import fs from 'node:fs';                    // built-in modules
import { readFile } from 'node:fs/promises';

// Dynamic import (works in both CJS and ESM)
const module = await import('./math.js');
```

### Key Differences

| Feature | CommonJS | ES Modules |
|---------|----------|------------|
| Syntax | `require()` / `module.exports` | `import` / `export` |
| Loading | Synchronous | Asynchronous |
| Top-level await | No | Yes |
| `__dirname` | Available | Use `import.meta.url` |
| File extension | `.js` or `.cjs` | `.js` (with type:module) or `.mjs` |
| JSON import | `require('./data.json')` | `import data from './data.json' assert {type:'json'}` |

```javascript
// ESM equivalent of __dirname and __filename
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
```

---

## Async/Await and Promises

### Promises

```javascript
// Creating a promise
function fetchData(url) {
  return new Promise((resolve, reject) => {
    // async operation
    if (success) resolve(data);
    else reject(new Error('Failed'));
  });
}

// Consuming
fetchData('http://api.example.com')
  .then(data => console.log(data))
  .catch(err => console.error(err))
  .finally(() => console.log('Done'));

// Promise utilities
Promise.all([p1, p2, p3])        // wait for all, fail if any fails
Promise.allSettled([p1, p2, p3]) // wait for all, get all results
Promise.race([p1, p2, p3])      // first to settle
Promise.any([p1, p2, p3])       // first to fulfill (ignores rejections)
```

### async/await (preferred)

```javascript
async function main() {
  try {
    const data = await fetchData('http://api.example.com');
    console.log(data);

    // Parallel execution
    const [users, posts] = await Promise.all([
      fetchUsers(),
      fetchPosts()
    ]);

    // Sequential
    const user = await getUser(1);
    const profile = await getProfile(user.id);
  } catch (err) {
    console.error('Error:', err.message);
  }
}

main();

// Top-level await (ES modules only)
const data = await fetchData('http://api.example.com');
```

### Promisifying Callbacks

```javascript
import { promisify } from 'node:util';
import { exec } from 'node:child_process';

const execAsync = promisify(exec);
const { stdout } = await execAsync('ls -la');

// fs already has a promises API
import { readFile, writeFile } from 'node:fs/promises';
const content = await readFile('file.txt', 'utf-8');
```

---

## EventEmitter

```javascript
import { EventEmitter } from 'node:events';

const emitter = new EventEmitter();

// Listen for events
emitter.on('data', (payload) => {
  console.log('Received:', payload);
});

emitter.once('connect', () => {
  console.log('Connected (fires only once)');
});

// Emit events
emitter.emit('connect');
emitter.emit('data', { temperature: 22.5 });

// Remove listeners
const handler = (data) => console.log(data);
emitter.on('data', handler);
emitter.off('data', handler);      // or removeListener

// Error handling (always listen for 'error')
emitter.on('error', (err) => {
  console.error('Error:', err.message);
});

// Custom class extending EventEmitter
class Sensor extends EventEmitter {
  start() {
    setInterval(() => {
      const value = Math.random() * 100;
      this.emit('reading', value);
    }, 1000);
  }
}

const sensor = new Sensor();
sensor.on('reading', (v) => console.log(`Value: ${v.toFixed(1)}`));
sensor.start();
```

---

## Core Modules

### fs (File System)

```javascript
import { readFile, writeFile, readdir, stat, mkdir, rm, rename, copyFile }
  from 'node:fs/promises';
import { createReadStream, createWriteStream } from 'node:fs';

// Read file
const content = await readFile('file.txt', 'utf-8');
const buffer = await readFile('image.png');  // returns Buffer

// Write file
await writeFile('output.txt', 'Hello\n');
await writeFile('data.json', JSON.stringify(data, null, 2));

// Append
import { appendFile } from 'node:fs/promises';
await appendFile('log.txt', `${new Date().toISOString()} Event\n`);

// Directory operations
await mkdir('new-dir', { recursive: true });
const files = await readdir('.');
const filesWithTypes = await readdir('.', { withFileTypes: true });
for (const f of filesWithTypes) {
  console.log(f.name, f.isDirectory() ? 'DIR' : 'FILE');
}

// File info
const info = await stat('file.txt');
console.log(info.size, info.mtime, info.isFile());

// Check existence
import { access, constants } from 'node:fs/promises';
try { await access('file.txt', constants.F_OK); } catch { /* not found */ }

// Delete
await rm('file.txt');
await rm('directory', { recursive: true, force: true });

// Rename / Move
await rename('old.txt', 'new.txt');

// Streaming (for large files)
const readStream = createReadStream('big-file.log');
const writeStream = createWriteStream('output.log');
readStream.pipe(writeStream);
```

### path

```javascript
import path from 'node:path';

path.join('a', 'b', 'c.txt')     // 'a/b/c.txt' (platform-aware)
path.resolve('relative/path')     // absolute path
path.basename('/a/b/c.txt')       // 'c.txt'
path.dirname('/a/b/c.txt')        // '/a/b'
path.extname('file.tar.gz')       // '.gz'
path.parse('/a/b/c.txt')          // { root:'/', dir:'/a/b', base:'c.txt', ext:'.txt', name:'c' }
path.isAbsolute('/home')          // true
path.relative('/a/b', '/a/c')     // '../c'
```

### http / https

```javascript
import http from 'node:http';

// Simple HTTP server
const server = http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);

  if (req.url === '/api/data') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ temperature: 22.5 }));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<h1>Hello</h1>');
  }
});

server.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});

// HTTP request (Node 18+ fetch)
const response = await fetch('https://api.example.com/data');
const data = await response.json();
```

---

## Express Basics

```javascript
import express from 'express';
const app = express();

// Middleware
app.use(express.json());                          // parse JSON bodies
app.use(express.urlencoded({ extended: true }));  // parse form data
app.use(express.static('public'));                 // serve static files

// Custom middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});

// Routes
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.get('/api/sensors', (req, res) => {
  res.json([{ id: 1, name: 'temp', value: 22.5 }]);
});

app.get('/api/sensors/:id', (req, res) => {
  const { id } = req.params;
  res.json({ id, value: 22.5 });
});

app.post('/api/sensors', (req, res) => {
  const { name, value } = req.body;
  // save to database...
  res.status(201).json({ id: 1, name, value });
});

// Query parameters: GET /api/data?limit=10&offset=0
app.get('/api/data', (req, res) => {
  const { limit = 10, offset = 0 } = req.query;
  // ...
});

// Error handling middleware (4 arguments)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(3000, () => console.log('Listening on :3000'));
```

---

## Serial Ports (serialport package)

Essential for communicating with Arduino, ESP32, GPS modules, radios, etc.

```bash
npm install serialport
```

```javascript
import { SerialPort } from 'serialport';
import { ReadlineParser } from '@serialport/parser-readline';

// List available ports
const ports = await SerialPort.list();
for (const p of ports) {
  console.log(p.path, p.manufacturer || '');
}

// Open a serial port
const port = new SerialPort({
  path: '/dev/ttyUSB0',  // or 'COM3' on Windows
  baudRate: 115200
});

// Parse incoming data by newline
const parser = port.pipe(new ReadlineParser({ delimiter: '\n' }));

// Read data
parser.on('data', (line) => {
  console.log('Received:', line.trim());
  // Parse sensor data: "TEMP:22.5,HUM:45.2"
  const pairs = line.trim().split(',');
  for (const pair of pairs) {
    const [key, val] = pair.split(':');
    console.log(`  ${key} = ${parseFloat(val)}`);
  }
});

// Write data
port.write('GET_SENSOR_DATA\n');

// Events
port.on('open', () => console.log('Port opened'));
port.on('error', (err) => console.error('Error:', err.message));
port.on('close', () => console.log('Port closed'));

// Binary data
port.write(Buffer.from([0x01, 0x02, 0x03]));

// Close
port.close();
```

---

## MQTT Client (mqtt.js)

MQTT is the standard protocol for IoT messaging.

```bash
npm install mqtt
```

```javascript
import mqtt from 'mqtt';

// Connect to broker
const client = mqtt.connect('mqtt://192.168.1.100:1883', {
  clientId: 'node-sensor-01',
  username: 'user',       // optional
  password: 'pass',       // optional
  reconnectPeriod: 5000,  // auto-reconnect
  will: {                 // last will (sent if client disconnects ungracefully)
    topic: 'devices/sensor-01/status',
    payload: 'offline',
    retain: true
  }
});

client.on('connect', () => {
  console.log('Connected to MQTT broker');

  // Subscribe
  client.subscribe('sensors/#');           // wildcard: all under sensors/
  client.subscribe('commands/sensor-01');   // specific topic

  // Publish
  client.publish('devices/sensor-01/status', 'online', { retain: true });
});

client.on('message', (topic, message) => {
  console.log(`${topic}: ${message.toString()}`);

  // Parse JSON payloads
  try {
    const data = JSON.parse(message.toString());
    console.log('Parsed:', data);
  } catch (e) {
    // plain text message
  }
});

// Publish sensor data periodically
setInterval(() => {
  const payload = JSON.stringify({
    temperature: 22.5 + Math.random(),
    humidity: 45.0 + Math.random() * 10,
    timestamp: Date.now()
  });
  client.publish('sensors/temp-01/data', payload);
}, 30000);

client.on('error', (err) => console.error('MQTT error:', err));
client.on('reconnect', () => console.log('Reconnecting...'));
client.on('offline', () => console.log('Client offline'));
```

---

## child_process

```javascript
import { exec, execFile, spawn } from 'node:child_process';
import { promisify } from 'node:util';

const execAsync = promisify(exec);

// exec — run shell command, buffer output
const { stdout, stderr } = await execAsync('ls -la');
console.log(stdout);

// execFile — run binary directly (safer, no shell)
const execFileAsync = promisify(execFile);
const { stdout: out } = await execFileAsync('git', ['status']);

// spawn — streaming output (for long-running processes)
const child = spawn('ping', ['-c', '5', '8.8.8.8']);

child.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

child.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

child.on('close', (code) => {
  console.log(`Process exited with code ${code}`);
});

// Send input to child
const child2 = spawn('cat', []);
child2.stdin.write('Hello\n');
child2.stdin.end();
```

---

## Buffer

Node.js Buffer handles binary data:

```javascript
// Create buffers
const buf1 = Buffer.alloc(10);               // 10 zero bytes
const buf2 = Buffer.from([0x48, 0x65, 0x6c]); // from byte array
const buf3 = Buffer.from('Hello', 'utf-8');    // from string
const buf4 = Buffer.from('AQID', 'base64');    // from base64

// Read/Write
buf1.writeUInt8(0xFF, 0);           // write byte at offset 0
buf1.writeUInt16BE(1024, 1);        // big-endian uint16 at offset 1
buf1.writeInt32LE(-1, 3);           // little-endian int32 at offset 3
buf1.writeFloatBE(3.14, 7);         // float at offset 7 (needs 4 bytes... careful with bounds)

const val = buf1.readUInt8(0);
const val16 = buf1.readUInt16BE(1);

// Convert
buf3.toString('utf-8')              // 'Hello'
buf3.toString('hex')                // '48656c6c6f'
buf3.toString('base64')             // 'SGVsbG8='

// Slice and copy
const slice = buf3.subarray(0, 3);   // shared memory!
const copy = Buffer.from(buf3);      // independent copy

// Compare
Buffer.compare(buf1, buf2)           // -1, 0, or 1
buf1.equals(buf2)                    // boolean

// Concatenate
const combined = Buffer.concat([buf1, buf2, buf3]);
```

---

## Streams

```javascript
import { createReadStream, createWriteStream } from 'node:fs';
import { pipeline } from 'node:stream/promises';
import { createGzip, createGunzip } from 'node:zlib';
import { Transform } from 'node:stream';

// Pipe: read -> transform -> write
await pipeline(
  createReadStream('input.txt'),
  createGzip(),
  createWriteStream('input.txt.gz')
);

// Custom transform stream
const upperCase = new Transform({
  transform(chunk, encoding, callback) {
    this.push(chunk.toString().toUpperCase());
    callback();
  }
});

await pipeline(
  createReadStream('input.txt'),
  upperCase,
  createWriteStream('output.txt')
);
```

---

## Environment Variables

```javascript
// Access
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';

// .env file support (install dotenv)
// npm install dotenv
import 'dotenv/config';
// or: import dotenv from 'dotenv'; dotenv.config();
// reads from .env file:
// PORT=3000
// DATABASE_URL=postgresql://localhost/mydb

// Node 20.6+ has built-in .env support
// node --env-file=.env app.js
```

---

## Debugging

```bash
# Start with inspector
node --inspect app.js            # debug on port 9229
node --inspect-brk app.js       # break on first line

# Open Chrome DevTools:
# chrome://inspect -> click "inspect" on your Node process

# Or use VS Code debugger (launch.json)
```

```javascript
// In code
console.log('basic log');
console.error('error log');
console.table([{a:1, b:2}, {a:3, b:4}]);
console.time('operation');
// ... do work ...
console.timeEnd('operation');    // operation: 123.456ms

debugger;  // breakpoint when running with --inspect
```

---

## Useful Patterns

### Graceful Shutdown

```javascript
function shutdown(signal) {
  console.log(`Received ${signal}, shutting down...`);
  server.close(() => {
    mqttClient.end();
    serialPort.close();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000); // force after 10s
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
```

### Simple File-Based Config

```javascript
import { readFile, writeFile } from 'node:fs/promises';

async function loadConfig(path = 'config.json') {
  try {
    return JSON.parse(await readFile(path, 'utf-8'));
  } catch {
    return {}; // default empty config
  }
}

async function saveConfig(config, path = 'config.json') {
  await writeFile(path, JSON.stringify(config, null, 2));
}
```

### Retry with Backoff

```javascript
async function retry(fn, maxAttempts = 3, baseDelay = 1000) {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt === maxAttempts) throw err;
      const delay = baseDelay * Math.pow(2, attempt - 1);
      console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
      await new Promise(r => setTimeout(r, delay));
    }
  }
}

const data = await retry(() => fetch('http://api.example.com/data'));
```
