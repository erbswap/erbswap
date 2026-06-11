// Demo-app glue. Not part of erbswap itself.
// In your own Rails app, hook into whatever modal system you already use
// (USWDS, Bootstrap, Bulma, etc.) instead of this snippet.
document.addEventListener("click", (event) => {
  const trigger = event.target.closest("[data-modal-open]");
  if (!trigger) return;
  const modal = document.getElementById(trigger.dataset.modalOpen);
  if (!modal || typeof modal.showModal !== "function") return;

  // Pattern B detail: clear the target frame to a placeholder before
  // showing the dialog. Without this, a previous swap's content
  // (success / empty / error state) would flash for ~200ms while the
  // fresh fetch is in flight. Reset-on-open, not reset-on-close.
  const frameId = trigger.dataset.erbswapTarget;
  if (frameId) {
    const frame = document.getElementById(frameId);
    if (frame) frame.innerHTML = '<p class="modal__placeholder">Loading…</p>';
  }

  modal.showModal();
});
