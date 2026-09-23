export function CSRFToken() {
  const metaTag = document.querySelector('meta[name="csrf-token"]');
  return metaTag ? metaTag.getAttribute("content") : null;
}

export function loadTurboContent(path) {
  return fetch(path, {
    headers: {
      Accept: "text/vnd.turbo-stream.html",
    },
  })
    .then((response) => response.text())
    .then((html) => {
      Turbo.renderStreamMessage(html);
    })
    .catch((error) => {
      console.error("Error fetching content:", error);
    });
}

export function fetchTurboContent(event, path) {
  event.preventDefault();

  return loadTurboContent(path);
}

export function markValid(event) {
  event.target.setCustomValidity("");
  event.target.checkValidity();
}
