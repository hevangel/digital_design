"use strict";

const home = "README.md";
const libraryURL = new URL(".", window.location.href);
const languages = [
  { label: "SystemVerilog", directory: "systemverilog", extension: "sv", grammar: "verilog" },
  { label: "VHDL", directory: "vhdl", extension: "vhd", grammar: "vhdl" }
];
const fenceGrammar = {
  sv: "verilog", systemverilog: "verilog", verilog: "verilog", vhdl: "vhdl", vhd: "vhdl"
};
const files = new Map();
const sections = [];
const cache = new Map();
const ui = {
  library: document.querySelector("#library"),
  navigation: document.querySelector("#navigation"),
  filter: document.querySelector("#find"),
  menu: document.querySelector(".menu-toggle"),
  content: document.querySelector("#content"),
  location: document.querySelector("#location"),
  article: document.querySelector("#document"),
  outline: document.querySelector("#outline"),
  tabs: document.querySelector("#languages"),
  source: document.querySelector("#source"),
  copy: document.querySelector("#copy"),
  status: document.querySelector("#status")
};

let selectedPath;
let revision = 0;
let currentSource = "";
let openBeforeFilter;

function element(tag, label, className) {
  const node = document.createElement(tag);
  if (label != null) node.textContent = label;
  if (className) node.className = className;
  return node;
}

function route(path, anchor) {
  return anchor ? `#${path}#${encodeURIComponent(anchor)}` : `#${path}`;
}

function readRoute() {
  const [path, anchor] = window.location.hash.slice(1).split("#");
  try {
    return { path: decodeURIComponent(path || home), anchor: decodeURIComponent(anchor || "") };
  } catch {
    return { path: "", anchor: "" };
  }
}

function registerFiles(catalog) {
  for (const group of catalog.documents) {
    const entries = Object.entries(group.files).map(([path, label]) => ({ path, label, group: group.title }));
    for (const entry of entries) files.set(entry.path, entry);
    sections.push({ title: group.title, entries, open: group.open ?? false });
  }
  for (const group of catalog.hdl) {
    const entries = [];
    if (group.index) {
      const entry = { path: `${group.directory}/README.md`, label: group.index, group: group.title };
      files.set(entry.path, entry);
      entries.push(entry);
    }
    for (const [basename, label] of Object.entries(group.files)) {
      const pair = languages.map(language => ({
        path: `${group.directory}/${language.directory}/${basename}.${language.extension}`,
        label,
        basename,
        language,
        group: group.title
      }));
      for (const entry of pair) {
        entry.pair = pair;
        files.set(entry.path, entry);
      }
      entries.push(pair[0]);
    }
    sections.push({ title: group.title, entries, open: false });
  }
}

function fileIsSelected(entry, path) {
  return entry.path === path || entry.pair?.some(member => member.path === path);
}

function drawLibrary(path) {
  const query = ui.filter.value.trim().toLowerCase();
  const current = new Map([...ui.navigation.querySelectorAll("details")].map(node => [node.dataset.group, node.open]));
  if (query && !openBeforeFilter) openBeforeFilter = current;
  const remembered = !query && openBeforeFilter ? openBeforeFilter : current;
  const fragment = document.createDocumentFragment();

  for (const section of sections) {
    const matches = section.entries.filter(entry => {
      const paths = entry.pair?.map(member => member.path).join(" ") || entry.path;
      return `${entry.label} ${entry.group} ${paths}`.toLowerCase().includes(query);
    });
    if (!matches.length) continue;

    const details = element("details");
    details.dataset.group = section.title;
    const hasActiveFile = matches.some(entry => fileIsSelected(entry, path));
    details.open = Boolean(query) || hasActiveFile || (remembered.get(section.title) ?? section.open);
    details.append(element("summary", section.title));
    const list = element("ul");
    for (const entry of matches) {
      const item = element("li");
      const link = element("a", entry.label);
      const active = fileIsSelected(entry, path);
      link.href = route(active ? path : entry.path);
      if (active) link.setAttribute("aria-current", "page");
      item.append(link);
      list.append(item);
    }
    details.append(list);
    fragment.append(details);
  }
  if (!fragment.childElementCount) fragment.append(element("p", "No matching files."));
  ui.navigation.replaceChildren(fragment);
  if (!query) openBeforeFilter = undefined;
}

async function loadText(path) {
  if (!cache.has(path)) {
    const response = await fetch(path);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    cache.set(path, await response.text());
  }
  return cache.get(path);
}

const markdown = new marked.Marked({
  gfm: true,
  extensions: [{
    // The example index uses empty named anchors to link to topic rows.
    name: "topicAnchor",
    level: "inline",
    start(text) {
      const offset = text.indexOf('<a id="');
      if (offset !== -1) return offset;
    },
    tokenizer(text) {
      const match = /^<a id="([a-z0-9-]+)"><\/a>/i.exec(text);
      if (match) return { type: "topicAnchor", raw: match[0], id: match[1] };
    },
    renderer({ id }) {
      return `<a id="${id}"></a>`;
    }
  }],
  renderer: {
    html({ text }) {
      return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
    }
  }
});

function highlight(code, grammar) {
  if (!grammar || !Prism.languages[grammar]) return;
  code.className = `language-${grammar}`;
  Prism.highlightElement(code);
}

function slug(text) {
  return text.trim().toLowerCase().replace(/[^\p{L}\p{N}\p{M}\s_-]/gu, "").replace(/\s/g, "-");
}

function withinLibrary(url) {
  return url.origin === libraryURL.origin && url.pathname.startsWith(libraryURL.pathname);
}

function rewriteLinks(fragment, path) {
  const base = new URL(path, libraryURL);
  for (const link of fragment.querySelectorAll("a[href]")) {
    const href = link.getAttribute("href");
    let target;
    try {
      target = new URL(href, base);
    } catch {
      link.removeAttribute("href");
      continue;
    }
    if (target.protocol === "mailto:") continue;
    if (target.protocol !== "http:" && target.protocol !== "https:") {
      link.removeAttribute("href");
      continue;
    }
    if (withinLibrary(target)) {
      const targetPath = target.pathname.slice(libraryURL.pathname.length);
      if (files.has(targetPath)) {
        try {
          link.href = route(targetPath, decodeURIComponent(target.hash.slice(1)));
        } catch {
          link.href = route(targetPath);
        }
        continue;
      }
    }
    link.href = target.href;
  }
  for (const image of fragment.querySelectorAll("img")) {
    let target;
    try {
      target = new URL(image.getAttribute("src"), base);
    } catch {
      image.replaceWith(document.createTextNode(image.alt));
      continue;
    }
    if (withinLibrary(target) && ["http:", "https:"].includes(target.protocol)) {
      image.src = target.href;
      image.loading = "lazy";
    } else {
      image.replaceWith(document.createTextNode(image.alt));
    }
  }
}

function renderMarkdown(source, path) {
  const template = element("template");
  template.innerHTML = markdown.parse(source);
  const fragment = template.content;
  const ids = new Set([...fragment.querySelectorAll("[id]")].map(node => node.id));
  const outline = element("ul");
  for (const heading of fragment.querySelectorAll("h1, h2, h3, h4, h5, h6")) {
    const label = heading.textContent;
    const base = slug(label) || "section";
    let id = base;
    for (let count = 1; ids.has(id); count += 1) id = `${base}-${count}`;
    ids.add(id);
    heading.id = id;
    if (!["H2", "H3"].includes(heading.tagName)) continue;
    const item = element("li", null, heading.tagName === "H3" ? "subheading" : "");
    const link = element("a", label);
    link.href = route(path, id);
    item.append(link);
    outline.append(item);
  }
  for (const table of fragment.querySelectorAll("table")) {
    const wrapper = element("div", null, "table-wrap");
    wrapper.tabIndex = 0;
    wrapper.setAttribute("role", "region");
    wrapper.setAttribute("aria-label", "Data table");
    table.replaceWith(wrapper);
    wrapper.append(table);
  }
  for (const code of fragment.querySelectorAll("pre > code")) {
    const language = code.className.replace(/^language-/, "").toLowerCase();
    if (Object.hasOwn(fenceGrammar, language)) highlight(code, fenceGrammar[language]);
    code.parentElement.tabIndex = 0;
  }
  rewriteLinks(fragment, path);
  ui.article.replaceChildren(fragment);
  ui.outline.replaceChildren(element("p", "On this page"), outline);
  ui.outline.hidden = !outline.childElementCount;
}

function renderCode(source, entry) {
  const title = element("h1", entry.path.split("/").at(-1));
  const pre = element("pre", null, "code-file");
  pre.tabIndex = 0;
  pre.setAttribute("aria-label", `${entry.language.label} source code`);
  const lineCount = source.replace(/\r?\n$/, "").split("\n").length;
  const gutter = element("span", Array.from({ length: lineCount }, (_, index) => index + 1).join("\n"), "line-numbers");
  gutter.setAttribute("aria-hidden", "true");
  const code = element("code", source);
  highlight(code, entry.language.grammar);
  pre.append(gutter, code);
  ui.article.replaceChildren(title, pre);
}

function scrollToAnchor(anchor) {
  if (!anchor) {
    window.scrollTo(0, 0);
    return;
  }
  const target = [...ui.article.querySelectorAll("[id]")].find(node => node.id === anchor);
  if (target) target.scrollIntoView();
}

function setMenu(open) {
  ui.library.classList.toggle("is-open", open);
  ui.menu.setAttribute("aria-expanded", String(open));
}

function resetDocument() {
  ui.article.replaceChildren();
  ui.article.classList.remove("code-document");
  ui.article.removeAttribute("aria-busy");
  ui.outline.hidden = true;
  ui.tabs.hidden = true;
  ui.source.hidden = true;
  ui.copy.hidden = true;
  ui.copy.textContent = "Copy code";
  currentSource = "";
}

async function showRoute() {
  const { path, anchor } = readRoute();
  if (selectedPath === path) {
    scrollToAnchor(anchor);
    return;
  }

  const request = ++revision;
  const entry = files.get(path);
  selectedPath = undefined;
  resetDocument();
  drawLibrary(path);
  if (!entry) {
    ui.location.textContent = "Study library";
    document.title = "File not found · Digital Design";
    ui.article.append(element("h1", "File not found"));
    ui.status.textContent = "Choose a file from the library.";
    scrollToAnchor("");
    return;
  }

  ui.location.textContent = `${entry.group} / ${entry.label}`;
  ui.status.textContent = "Loading…";
  ui.article.setAttribute("aria-busy", "true");
  try {
    const source = await loadText(path);
    if (request !== revision) return;
    ui.status.textContent = "";
    selectedPath = path;
    ui.source.href = path;
    ui.source.hidden = false;
    document.title = `${entry.label} · Digital Design`;

    if (entry.language) {
      currentSource = source;
      ui.article.classList.add("code-document");
      ui.tabs.replaceChildren(...entry.pair.map(member => {
        const link = element("a", member.language.label);
        link.href = route(member.path);
        if (member.path === path) link.setAttribute("aria-current", "page");
        return link;
      }));
      ui.tabs.hidden = false;
      ui.copy.hidden = false;
      renderCode(source, entry);
    } else {
      renderMarkdown(source, path);
    }
    scrollToAnchor(anchor);
  } catch {
    if (request !== revision) return;
    selectedPath = undefined;
    resetDocument();
    ui.status.textContent = "Could not load this file. Choose another file or reload the reader.";
  } finally {
    if (request === revision) ui.article.removeAttribute("aria-busy");
  }
}

ui.menu.addEventListener("click", () => {
  const open = ui.menu.getAttribute("aria-expanded") !== "true";
  setMenu(open);
  if (open) ui.filter.focus();
});
ui.library.addEventListener("keydown", event => {
  if (event.key === "Escape" && ui.menu.getAttribute("aria-expanded") === "true") {
    setMenu(false);
    ui.menu.focus();
  }
});
ui.navigation.addEventListener("click", event => {
  if (!event.target.closest("a") || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
  setMenu(false);
  ui.content.focus({ preventScroll: true });
});
ui.filter.addEventListener("input", () => drawLibrary(readRoute().path));
document.querySelector(".skip-link").addEventListener("click", event => {
  event.preventDefault();
  ui.content.focus();
});
ui.copy.addEventListener("click", async () => {
  const path = selectedPath;
  try {
    await navigator.clipboard.writeText(currentSource);
    if (path === selectedPath) {
      ui.copy.textContent = "Copied";
      ui.status.textContent = "Source copied to clipboard.";
    }
  } catch {
    if (path === selectedPath) ui.status.textContent = "Clipboard unavailable. Use Open source to copy the file.";
  }
});

async function start() {
  if (window.location.protocol === "file:") {
    ui.status.textContent = "Serve this directory over HTTP to browse files. See the README for a local command.";
    ui.source.href = home;
    ui.source.hidden = false;
    return;
  }
  try {
    registerFiles(JSON.parse(await loadText("assets/library.json")));
    window.addEventListener("hashchange", showRoute);
    await showRoute();
  } catch {
    ui.status.textContent = "Could not load the library. Reload the reader or open the Markdown index directly.";
    ui.source.href = home;
    ui.source.hidden = false;
  }
}

start();
