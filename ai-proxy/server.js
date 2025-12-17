import express from "express";

const app = express();
app.use(express.json());

const GROQ_API_KEY = process.env.GROQ_API_KEY;
if (!GROQ_API_KEY) throw new Error("Missing GROQ_API_KEY");

// Agents = personnalités. L’humanité = prompts en boucle, nous = structure.
const AGENTS = {
  strudel: {
    system:
      "Dev Strudel/Tidal. Réponds court. Code d'abord. Patterns prêts à coller. Humour sec.",
    defaults: { temperature: 0.4, top_p: 0.9, max_tokens: 800 },
  },
  n8n: {
    system:
      "Dev n8n/Docker/Nginx. Étapes actionnables. JSON/env vars quand utile. Zéro blabla.",
    defaults: { temperature: 0.2, top_p: 0.8, max_tokens: 900 },
  },
  js: {
    system:
      "Expert JavaScript. Code minimal, sûr, explications courtes. Refactor si besoin.",
    defaults: { temperature: 0.2, top_p: 0.9, max_tokens: 900 },
  },
};

// ✅ Routes attendues derrière ton Nginx actuel:
// /api/health -> backend /health
// /api/models -> backend /models
// /api/chat   -> backend /chat
app.get("/health", (req, res) => res.json({ ok: true }));

app.get("/models", async (req, res) => {
  try {
    const r = await fetch("https://api.groq.com/openai/v1/models", {
      headers: { Authorization: `Bearer ${GROQ_API_KEY}` },
    });
    const data = await r.json();
    return res.status(r.ok ? 200 : r.status).json(data);
  } catch (e) {
    return res.status(500).json({ error: String(e?.message || e) });
  }
});

app.post("/chat", async (req, res) => {
  try {
    const { model, agent, messages, overrides } = req.body || {};

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ error: "Missing messages[]" });
    }

    const a = AGENTS[agent] ?? AGENTS.js;
    const opts = { ...a.defaults, ...(overrides || {}) };

    const payload = {
      model: model || "llama3-70b-8192",
      messages: [{ role: "system", content: a.system }, ...messages],
      temperature: opts.temperature,
      top_p: opts.top_p,
      max_tokens: opts.max_tokens,
    };

    const r = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const data = await r.json();
    if (!r.ok) return res.status(r.status).json(data);

    return res.json({
      text: data?.choices?.[0]?.message?.content ?? "",
      model: data?.model,
      usage: data?.usage,
    });
  } catch (e) {
    return res.status(500).json({ error: String(e?.message || e) });
  }
});

app.listen(3101, () => console.log("AI proxy on :3101"));
