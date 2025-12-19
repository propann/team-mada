const statusBadge = document.getElementById("jeux-status");

async function checkJeuxText() {
  try {
    const res = await fetch("/jeux-text/health", { cache: "no-store" });
    if (res.ok) {
      statusBadge.textContent = "ONLINE";
      statusBadge.classList.remove("ko");
      statusBadge.classList.add("ok");
      return;
    }
  } catch (e) {
    // ignore
  }
  statusBadge.textContent = "OFFLINE";
  statusBadge.classList.remove("ok");
  statusBadge.classList.add("ko");
}

document.addEventListener("DOMContentLoaded", () => {
  checkJeuxText();
  setInterval(checkJeuxText, 10000);
});
