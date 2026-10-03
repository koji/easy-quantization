#!/bin/sh
set -eu

uv sync
uv pip uninstall hf-xet || true

if [ ! -d "llama.cpp" ]; then
  git clone https://github.com/ggml-org/llama.cpp.git
fi

cmake -S llama.cpp -B llama.cpp/build -DGGML_METAL=ON -DLLAMA_CURL=OFF
cmake --build llama.cpp/build --config Release -j 8
