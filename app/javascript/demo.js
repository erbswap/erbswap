// Demo-app glue. Not part of erbswap itself.
// In your own Rails app, hook into whatever modal system you already use
// (USWDS, Bootstrap, Bulma, etc.) instead of this snippet.
document.addEventListener("click", (event) => {
  const trigger = event.target.closest("[data-modal-open]");
  if (!trigger) return;
  const modal = document.getElementById(trigger.dataset.modalOpen);
  if (modal && typeof modal.showModal === "function") {
    modal.showModal();
  }
});
