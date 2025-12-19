(() => {
  const output = document.getElementById("output");
  const form = document.getElementById("command-form");
  const input = document.getElementById("command");

  const STORAGE_KEY = "jeux-text-state-v1";
  let scenes = {};
  let state = {
    currentScene: null,
    inventory: [],
    visited: new Set(),
  };

  const serializeState = () => ({
    currentScene: state.currentScene,
    inventory: state.inventory,
    visited: Array.from(state.visited),
  });

  const restoreState = (raw) => {
    try {
      const parsed = JSON.parse(raw);
      state.currentScene = parsed.currentScene ?? null;
      state.inventory = Array.isArray(parsed.inventory) ? parsed.inventory : [];
      state.visited = new Set(Array.isArray(parsed.visited) ? parsed.visited : []);
    } catch (e) {
      state = { currentScene: null, inventory: [], visited: new Set() };
    }
  };

  const saveState = () => {
    const payload = serializeState();
    localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
  };

  const pushLine = (text, type = "") => {
    const line = document.createElement("div");
    line.className = `log-line ${type}`.trim();
    line.textContent = text;
    output.appendChild(line);
    output.scrollTop = output.scrollHeight;
  };

  const pushCommand = (cmd) => {
    const line = document.createElement("div");
    line.className = "log-line";
    line.innerHTML = `<span class="prompt">$</span> ${cmd}`;
    output.appendChild(line);
  };

  const printHelp = () => {
    pushLine("Commandes disponibles :", "system");
    [
      "start - démarrer ou réinitialiser la partie",
      "look - réafficher la scène courante",
      "go <scene> - se déplacer (ex: go couloir)",
      "inventory - lister les objets trouvés",
      "clear - nettoyer l'écran",
      "help - afficher cette aide",
    ].forEach((cmd) => pushLine(` • ${cmd}`, "system"));
  };

  const describeScene = (sceneId) => {
    const scene = scenes[sceneId];
    if (!scene) {
      pushLine("Cette destination n'existe pas.", "error");
      return;
    }

    state.currentScene = sceneId;
    if (!state.visited.has(sceneId)) {
      state.visited.add(sceneId);
      if (Array.isArray(scene.items)) {
        scene.items.forEach((item) => {
          if (!state.inventory.includes(item)) {
            state.inventory.push(item);
            pushLine(`+ ${item}`, "success");
          }
        });
      }
    }

    pushLine(`[${scene.title}]`, "success");
    pushLine(scene.description, "system");

    if (Array.isArray(scene.options) && scene.options.length > 0) {
      pushLine("Options :", "system");
      scene.options.forEach((opt) => pushLine(` • ${opt.label}`, "system"));
    }

    saveState();
  };

  const handleStart = () => {
    output.innerHTML = "";
    state = { currentScene: null, inventory: [], visited: new Set() };
    pushLine("=== NOUVELLE PARTIE ===", "success");
    describeScene("intro");
  };

  const handleLook = () => {
    if (!state.currentScene) {
      pushLine("Tape 'start' pour commencer.", "error");
      return;
    }
    describeScene(state.currentScene);
  };

  const handleGo = (target) => {
    if (!state.currentScene) {
      pushLine("Commence par 'start'.", "error");
      return;
    }
    const current = scenes[state.currentScene];
    const allowed = (current.options || []).some((opt) => opt.target === target);
    if (!allowed) {
      pushLine("Impossible d'y aller depuis ici.", "error");
      return;
    }
    describeScene(target);
  };

  const handleInventory = () => {
    if (!state.inventory.length) {
      pushLine("Inventaire vide.", "system");
      return;
    }
    pushLine("Inventaire :", "system");
    state.inventory.forEach((item) => pushLine(` • ${item}`, "system"));
  };

  const handleInput = (cmdRaw) => {
    const cmd = cmdRaw.trim();
    if (!cmd) return;
    pushCommand(cmd);

    const [base, ...rest] = cmd.split(/\s+/);
    switch (base.toLowerCase()) {
      case "help":
        printHelp();
        break;
      case "start":
        handleStart();
        break;
      case "look":
        handleLook();
        break;
      case "go":
        handleGo(rest[0]);
        break;
      case "inventory":
        handleInventory();
        break;
      case "clear":
        output.innerHTML = "";
        break;
      default:
        pushLine("Commande inconnue. Tape 'help'.", "error");
    }
  };

  const boot = async () => {
    try {
      const res = await fetch("scenes.json", { cache: "no-store" });
      scenes = await res.json();
    } catch (e) {
      pushLine("Impossible de charger les scènes.", "error");
      return;
    }

    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) restoreState(saved);

    pushLine("Bienvenue dans JEUX-TEXT. Tape 'help' pour l'aide ou 'start' pour commencer.", "system");

    if (state.currentScene && scenes[state.currentScene]) {
      describeScene(state.currentScene);
    }
  };

  form.addEventListener("submit", (evt) => {
    evt.preventDefault();
    const cmd = input.value;
    input.value = "";
    handleInput(cmd);
    input.focus();
  });

  boot();
})();
