// erbswap - Rails ERB partials + fetch + DOM swap. Under 200 lines, zero dependencies.
// https://github.com/erbswap/erbswap
(function () {
  if (window.erbswap) return;

  const SELECTOR = "[data-erbswap-src]";
  const DEFAULT_ERROR_HTML = '<div class="erbswap-error">Something went wrong.</div>';

  function dispatch(name, detail = {}) {
    document.dispatchEvent(new CustomEvent(`erbswap:${name}`, { detail }));
  }

  function csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : null;
  }

  function resolveTarget(targetOrId) {
    if (!targetOrId) return null;
    if (targetOrId instanceof Element) return targetOrId;
    if (typeof targetOrId === "string" && targetOrId.startsWith("#")) {
      return document.querySelector(targetOrId);
    }
    return document.getElementById(targetOrId);
  }

  function setLoadingState(target, loading) {
    if (!target) return;
    target.dataset.erbswapLoading = loading ? "true" : "false";
    target.classList.toggle("erbswap-loading", loading);
    target.setAttribute("aria-busy", loading ? "true" : "false");
  }

  function setSubmitterState(submitter, loading) {
    if (!submitter) return;

    if (loading) {
      submitter.dataset.erbswapOriginalText =
        submitter.tagName === "INPUT" ? submitter.value : submitter.innerHTML;
      submitter.disabled = true;
      submitter.setAttribute("aria-disabled", "true");
      submitter.classList.add("erbswap-submit-loading");

      const loadingText = submitter.dataset.erbswapLoadingText || "Processing...";
      if (submitter.tagName === "INPUT") {
        submitter.value = loadingText;
      } else {
        submitter.innerHTML = loadingText;
      }
    } else {
      submitter.disabled = false;
      submitter.setAttribute("aria-disabled", "false");
      submitter.classList.remove("erbswap-submit-loading");

      const originalText = submitter.dataset.erbswapOriginalText;
      if (originalText) {
        if (submitter.tagName === "INPUT") {
          submitter.value = originalText;
        } else {
          submitter.innerHTML = originalText;
        }
      }
    }
  }

  async function load(url, targetOrId, options = {}) {
    const target = resolveTarget(targetOrId);
    if (!url || !target) return null;

    const {
      method = "GET",
      body,
      headers = {},
      swap = "innerHTML",
      onSuccess,
      onError,
      errorHtml = target.dataset.erbswapErrorHtml || DEFAULT_ERROR_HTML,
    } = options;

    setLoadingState(target, true);
    dispatch("before-load", { url, target });

    const unsafe = method !== "GET" && method !== "HEAD";
    const token = unsafe ? csrfToken() : null;

    try {
      const response = await fetch(url, {
        method,
        body,
        credentials: "same-origin",
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "Accept": "text/html, */*; q=0.01",
          ...(token ? { "X-CSRF-Token": token } : {}),
          ...headers,
        },
      });

      // 4xx is a valid swap (e.g. 422 with a validation-error partial).
      // Only 5xx and network failures fall through to the error path.
      if (response.status >= 500) {
        throw new Error(`erbswap request failed: ${response.status}`);
      }

      const html = await response.text();
      if (swap === "replace") {
        target.outerHTML = html;
      } else {
        target.innerHTML = html;
      }

      target.dataset.erbswapLoaded = "true";
      dispatch("after-load", { url, target, html });
      if (typeof onSuccess === "function") onSuccess({ html, target, response });
      return html;
    } catch (error) {
      target.dataset.erbswapError = "true";
      if (swap !== "replace") target.innerHTML = errorHtml;
      dispatch("error", { url, target, error });
      if (typeof onError === "function") onError({ error, target });
      return null;
    } finally {
      setLoadingState(target, false);
    }
  }

  function scan(root = document) {
    root.querySelectorAll(SELECTOR).forEach((el) => {
      if (el.dataset.erbswapAction) return;
      if (el.dataset.erbswapAutoload === "false") return;
      if (el.dataset.erbswapLoaded === "true") return;
      if (el.dataset.erbswapLoading === "true") return;

      load(el.dataset.erbswapSrc, el, {
        swap: el.dataset.erbswapSwap || "innerHTML",
      });
    });
  }

  function bindActions(root = document) {
    root.addEventListener("click", async (event) => {
      const trigger = event.target.closest("[data-erbswap-action='load']");
      if (!trigger) return;

      const url = trigger.dataset.erbswapSrc || trigger.getAttribute("href");
      const target = trigger.dataset.erbswapTarget;
      if (!url || !target) return;

      event.preventDefault();
      await load(url, target, {
        swap: trigger.dataset.erbswapSwap || "innerHTML",
      });
    });

    root.addEventListener("submit", async (event) => {
      const form = event.target.closest("form[data-erbswap-form='true']");
      if (!form) return;

      const target = form.dataset.erbswapTarget;
      if (!target) return;

      event.preventDefault();

      const submitter = event.submitter;
      setSubmitterState(submitter, true);
      form.classList.add("erbswap-form-loading");

      const method = (form.method || "POST").toUpperCase();
      const isGet = method === "GET";
      const formData = new FormData(form);
      const url = isGet
        ? `${form.action}?${new URLSearchParams(formData).toString()}`
        : form.action;

      try {
        await load(url, target, {
          method,
          body: isGet ? undefined : formData,
          swap: form.dataset.erbswapSwap || "innerHTML",
        });
      } finally {
        form.classList.remove("erbswap-form-loading");
        setSubmitterState(submitter, false);
      }
    });
  }

  bindActions(document);

  document.addEventListener("DOMContentLoaded", () => scan(document));
  document.addEventListener("turbo:load", () => scan(document));
  document.addEventListener("turbo:render", () => scan(document));

  window.erbswap = { load, scan };
})();
