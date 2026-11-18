import { readFile } from "node:fs/promises";
import { createServer } from "node:http";

const port = Number(process.env.PORT || 4181);
const root = new URL("../", import.meta.url);
const extensions = new Map([
  ["html", "text/html"], ["css", "text/css"], ["js", "text/javascript"], ["json", "application/json"],
  ["md", "text/plain"], ["sv", "text/plain"], ["vhd", "text/plain"], ["csv", "text/csv"],
  ["sh", "text/plain"]
]);
const publicPath = /^(?:index\.html|README\.md|LICENSE|(?:assets|editions|notes|examples|tests|review)(?:\/[a-zA-Z0-9_-]+)*\/[a-zA-Z0-9_.-]+)$/;

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
  if (!publicPath.test(path)) {
    response.writeHead(404).end();
    return;
  }

  try {
    const bytes = await readFile(new URL(path, root));
    const type = extensions.get(path.split(".").at(-1)) || "text/plain";
    response.writeHead(200, { "Content-Type": `${type}; charset=utf-8`, "X-Content-Type-Options": "nosniff" });
    response.end(request.method === "HEAD" ? undefined : bytes);
  } catch (error) {
    response.writeHead(error.code === "ENOENT" || error.code === "EISDIR" ? 404 : 500).end();
  }
});

server.listen(port, "127.0.0.1", () => console.log(`Digital Design reader: http://127.0.0.1:${server.address().port}/`));
