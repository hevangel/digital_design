"use strict";

const textbook = (() => {
  const panel = document.querySelector("#textbook");
  const editionPicker = document.querySelector("#edition");
  const previous = document.querySelector("#previous-page");
  const next = document.querySelector("#next-page");
  const toggle = document.querySelector("#toggle-textbook");
  const counter = document.querySelector("#page-number");
  const status = document.querySelector("#textbook-status");
  const viewport = document.querySelector("#textbook-viewport");
  const sheet = document.querySelector("#textbook-sheet");
  const vendor = new URL("vendor/pdfjs/", document.currentScript.src);
  const documents = new Map();
  let pdfLibrary;
  let catalog;
  let editions = [];
  let path;
  let anchor;
  let basename;
  let sectionPage;
  let page;
  let totalPages;
  let width;
  let renderTask;
  let renderRevision = 0;

  function pdfURL(edition) {
    return new URL(`textbooks/${edition.file}`, window.location.href);
  }

  async function openPDF(edition) {
    if (!documents.has(edition.file)) {
      pdfLibrary ??= import(new URL("build/pdf.min.mjs", vendor)).then(pdfjs => {
        pdfjs.GlobalWorkerOptions.workerSrc = new URL("build/pdf.worker.min.mjs", vendor).href;
        return pdfjs;
      }).catch(error => {
        pdfLibrary = undefined;
        throw error;
      });
      const pending = pdfLibrary.then(pdfjs => {
        const task = pdfjs.getDocument({
          url: pdfURL(edition).href,
          disableAutoFetch: true,
          disableStream: true,
          standardFontDataUrl: new URL("standard_fonts/", vendor).href,
          wasmUrl: new URL("wasm/", vendor).href
        });
        return task.promise.catch(async error => {
          await task.destroy();
          throw error;
        });
      }).catch(error => {
        documents.delete(edition.file);
        throw error;
      });
      documents.set(edition.file, pending);
    }
    return documents.get(edition.file);
  }

  function showStatus(message) {
    status.textContent = message;
    status.hidden = !message;
  }

  function clearPage() {
    sheet.replaceChildren();
    counter.textContent = "";
    counter.removeAttribute("aria-label");
    previous.disabled = true;
    next.disabled = true;
  }

  function formatPage(template, page, total) {
    return template.replace("{page}", page).replace("{total}", total);
  }

  async function renderPage(preserveScroll = false) {
    const request = ++renderRevision;
    renderTask?.cancel();
    renderTask = undefined;
    panel.removeAttribute("aria-busy");
    if (panel.hidden) return;
    if (!page) {
      clearPage();
      showStatus(path ? catalog.ui.unmapped : "");
      return;
    }

    const edition = editions[editionPicker.selectedIndex];
    const requestedPage = page;
    width = viewport.clientWidth;
    panel.setAttribute("aria-busy", "true");
    showStatus(catalog.ui.loading);
    try {
      const pdf = await openPDF(edition);
      if (request !== renderRevision) return;
      totalPages = pdf.numPages;
      const pdfPage = await pdf.getPage(requestedPage);
      if (request !== renderRevision) return;

      const canvas = document.createElement("canvas");
      const natural = pdfPage.getViewport({ scale: 1 });
      const pixelRatio = Math.min(window.devicePixelRatio || 1, 2);
      const scale = Math.min(width * pixelRatio, 4096) / natural.width;
      const dimensions = pdfPage.getViewport({ scale });
      canvas.width = Math.ceil(dimensions.width);
      canvas.height = Math.ceil(dimensions.height);
      const label = formatPage(catalog.ui.page, requestedPage, pdf.numPages);
      canvas.setAttribute("role", "img");
      canvas.setAttribute("aria-label", `${edition.label} · ${label}`);
      renderTask = pdfPage.render({ canvas, viewport: dimensions });
      await renderTask.promise;
      if (request !== renderRevision) return;

      sheet.replaceChildren(canvas);
      if (!preserveScroll) viewport.scrollTop = 0;
      counter.textContent = formatPage(catalog.ui.pageCounter, requestedPage, pdf.numPages);
      counter.setAttribute("aria-label", label);
      previous.disabled = requestedPage <= 1;
      next.disabled = requestedPage >= pdf.numPages;
      showStatus("");
    } catch {
      if (request !== renderRevision) return;
      clearPage();
      showStatus(catalog.ui.failed);
    } finally {
      if (request === renderRevision) {
        panel.removeAttribute("aria-busy");
        renderTask = undefined;
      }
    }
  }

  function follow(nextPath, nextAnchor, nextBasename, force = false) {
    const changedPath = path !== nextPath;
    path = nextPath;
    anchor = nextAnchor;
    basename = nextBasename;
    toggle.hidden = !editions.length || (!path && panel.hidden);
    if (!editions.length) return;
    const edition = editions[editionPicker.selectedIndex];
    const key = catalog.aliases[basename] ?? path;
    const targets = catalog.sections[key];
    const target = !path ? undefined
      : targets ? (targets[anchor] ?? targets[""])[edition.index]
      : edition.contents;
    if (!force && !changedPath && target === sectionPage) return;
    sectionPage = target;
    page = target;
    if (!panel.hidden) renderPage();
  }

  editionPicker.addEventListener("change", () => {
    clearPage();
    follow(path, anchor, basename, true);
  });
  previous.addEventListener("click", () => {
    if (page <= 1) return;
    page -= 1;
    renderPage();
  });
  next.addEventListener("click", () => {
    if (page >= totalPages) return;
    page += 1;
    renderPage();
  });
  function setVisible(open) {
    panel.hidden = !open;
    toggle.hidden = !open && !path;
    toggle.setAttribute("aria-expanded", String(open));
    if (open) {
      clearPage();
      follow(path, anchor, basename, true);
    } else {
      renderPage();
    }
  }

  const resize = new ResizeObserver(() => {
    if (!panel.hidden && page && viewport.clientWidth !== width) renderPage(true);
  });
  resize.observe(viewport);

  async function init() {
    try {
      const response = await fetch("data/textbooks.json");
      if (!response.ok) return;
      catalog = await response.json();
    } catch {
      return;
    }
    // Static hosts do not have to expose directory listings. A PDF HEAD checks
    // both that the local folder is served and that the edition is present.
    const available = await Promise.all(catalog.editions.map(async (edition, index) => {
      try {
        const response = await fetch(pdfURL(edition), { method: "HEAD" });
        if (response.ok && response.headers.get("content-type")?.startsWith("application/pdf")) {
          return { ...edition, index };
        }
      } catch {
        return undefined;
      }
    }));
    editions = available.filter(Boolean);
    if (!editions.length) return;

    panel.setAttribute("aria-label", catalog.ui.viewer);
    editionPicker.setAttribute("aria-label", catalog.ui.edition);
    previous.textContent = catalog.ui.previous;
    next.textContent = catalog.ui.next;
    toggle.querySelector(".show-label").textContent = catalog.ui.show;
    toggle.querySelector(".hide-label").textContent = catalog.ui.hide;
    editionPicker.replaceChildren(...editions.map(edition => new Option(edition.label)));
    editionPicker.selectedIndex = editions.length - 1;
    follow(path, anchor, basename);
  }

  return { init, follow, setVisible };
})();
