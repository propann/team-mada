from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Union, Optional
from fastembed import TextEmbedding
import os

MODEL = os.getenv("EMBED_MODEL", "BAAI/bge-base-en-v1.5")

app = FastAPI(title="Az-Embed", version="1.0")
emb = TextEmbedding(model_name=MODEL)

class EmbReq(BaseModel):
    input: Union[str, List[str]]
    model: Optional[str] = None

@app.get("/health")
def health():
    return {"ok": True, "model": MODEL}

@app.post("/embeddings")
def embeddings(req: EmbReq):
    texts = [req.input] if isinstance(req.input, str) else req.input
    vectors = list(emb.embed(texts))
    data = [{"object": "embedding", "index": i, "embedding": v.tolist()} for i, v in enumerate(vectors)]
    return {"object": "list", "data": data, "model": MODEL}
