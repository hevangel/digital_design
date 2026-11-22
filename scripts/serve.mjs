import { createReadStream } from "node:fs";
import { readFile, stat } from "node:fs/promises";
import { createServer } from "node:http";
import { pipeline } from "node:stream/promises";

const port = Number(process.env.PORT || 4181);
const root = new URL("../", import.meta.url);
const extensions = new Map([
  ["html", "text/html"], ["css", "text/css"], ["js", "text/javascript"], ["json", "application/json"],
  ["md", "text/plain"], ["sv", "text/plain"], ["vhd", "text/plain"], ["csv", "text/csv"],
  ["sh", "text/plain"], ["mjs", "text/javascript"], ["wasm", "application/wasm"],
  ["ttf", "font/ttf"], ["pfb", "application/octet-stream"]
]);
const publicPath = /^(?:index\.html|README\.md|LICENSE|(?:assets|data|editions|notes|examples|tests|review)(?:\/[a-zA-Z0-9_-]+)*\/[a-zA-Z0-9_.-]+)$/;
const textbookPath = /^textbooks\/[a-zA-Z0-9_-]+\.pdf$/;

async function servePDF(request, response, file) {
  const info = await stat(file);
  if (!info.isFile() || !info.size) {
    response.writeHead(404).end();
    return;
  }

  const headers = {
    "Accept-Ranges": "bytes",
    "Content-Type": "application/pdf",
    "Content-Length": info.size,
    "X-Content-Type-Options": "nosniff"
  };
  if (request.method === "HEAD") {
    response.writeHead(200, headers).end();
    return;
  }

  const range = request.headers.range;
  if (!range) {
    response.writeHead(200, headers);
    await pipeline(createReadStream(file), response);
    return;
  }
  const match = /^bytes=(\d*)-(\d*)$/.exec(range);
  const start = match?.[1] ? Number(match[1]) : Math.max(0, info.size - Number(match?.[2]));
  const end = match?.[1] && match[2] ? Math.min(Number(match[2]), info.size - 1) : info.size - 1;
  if (!Number.isSafeInteger(start) || start > end) {
    response.writeHead(416, { "Content-Range": `bytes */${info.size}` }).end();
    return;
  }
  response.writeHead(206, {
    ...headers,
    "Content-Range": `bytes ${start}-${end}/${info.size}`,
    "Content-Length": end - start + 1
  });
  await pipeline(createReadStream(file, { start, end }), response);
}

const server = createServer(async (request, response) => {
  if (!["GET", "HEAD"].includes(request.method)) {
    response.writeHead(405, { Allow: "GET, HEAD" }).end();
    return;
  }

  let path;
  try {
    path = decodeURIComponent(new URL(request.url, "http://localhost").pathname.slice(1)) || "index.html";
  } catch {
    response.writeHead(400).end();
    return;
  }
  const isTextbook = textbookPath.test(path);
  if (!isTextbook && !publicPath.test(path)) {
    response.writeHead(404).end();
    return;
  }

  try {
    const file = new URL(path, root);
    if (isTextbook) {
      await servePDF(request, response, file);
      return;
    }
    const bytes = await readFile(file);
    const type = extensions.get(path.split(".").at(-1)) || "text/plain";
    response.writeHead(200, { "Content-Type": type, "X-Content-Type-Options": "nosniff" });
    response.end(request.method === "HEAD" ? undefined : bytes);
  } catch (error) {
    if (!response.headersSent && !response.destroyed) {
      response.writeHead(["ENOENT", "EISDIR", "ENOTDIR"].includes(error.code) ? 404 : 500).end();
    }
  }
});

server.listen(port, "127.0.0.1", () => console.log(`Digital Design reader: http://127.0.0.1:${server.address().port}/`));
