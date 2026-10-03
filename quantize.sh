#!/bin/sh
set -eu
# 使い方: MODEL_ID=google/gemma-4-E4B-it QUANT=Q4_K_M ./quantize.sh

MODEL_ID="${MODEL_ID:-google/gemma-4-E4B-it}"
MODEL_NAME="$(basename "$MODEL_ID")"
QUANT="${QUANT:-Q4_K_M}"
SRC="models/$MODEL_NAME"
BF16="gguf/$MODEL_NAME-BF16.gguf"
OUT="gguf/$MODEL_NAME-$QUANT.gguf"
QUANTIZE="llama.cpp/build/bin/llama-quantize"

[ -x "$QUANTIZE" ] || { echo "先に ./macOS_setup.sh を実行してください"; exit 1; }
uv run hf auth whoami >/dev/null || { echo "先に uv run hf auth login を実行してください"; exit 1; }

mkdir -p models gguf
uv run hf download "$MODEL_ID" --local-dir "$SRC"
[ -f "$BF16" ] || uv run python llama.cpp/convert_hf_to_gguf.py "$SRC" --outfile "$BF16" --outtype bf16
[ -f "$OUT" ] || "$QUANTIZE" "$BF16" "$OUT" "$QUANT"
