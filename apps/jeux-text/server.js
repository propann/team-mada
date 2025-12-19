import http from "http";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PORT = process.env.PORT || 8080;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
};

const send = (res, status, data, headers = {}) => {
  res.writeHead(status, headers);
  res.end(data);
};

const serveStatic = (urlPath, res) => {
  const target = urlPath === "/" ? "/index.html" : urlPath;
  const filePath = path.join(__dirname, target);
  if (!filePath.startsWith(__dirname)) {
    return send(res, 403, "forbidden");
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      return send(res, 404, "not found");
    }
    const ext = path.extname(filePath);
    const type = MIME[ext] || "text/plain";
    send(res, 200, data, { "Content-Type": type });
  });
};

const server = http.createServer((req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    return send(res, 200, JSON.stringify({ ok: true }), {
      "Content-Type": "application/json; charset=utf-8",
    });
  }

  if (req.method === "GET") {
    serveStatic(req.url.split("?")[0], res);
    return;
  }

  send(res, 405, "method not allowed");
});

server.listen(PORT, () => {
  console.log(`JEUX-TEXT ready on :${PORT}`);
});
