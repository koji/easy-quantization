# quantization

A starter repo for LLM quantization and GGUF conversion.

## Overview

- Goal: fetch a Hugging Face model and quantize it into `gguf/`.
- Layout: `macOS_setup.sh` (environment setup), `quantize.sh` (download → convert → quantize).

## How it works

Inferred from the dependencies in `pyproject.toml`:

- `transformers` + `huggingface-hub`: model download and loading
- `torch`: quantization compute
- `sentencepiece` + `protobuf`: tokenizer handling
- `gguf`: GGUF output

## Requirements

- macOS
- llama.cpp (Metal build): `./macOS_setup.sh` handles clone through build

```sh
./macOS_setup.sh
```

To do it manually:

```sh
git clone https://github.com/ggml-org/llama.cpp.git
cmake -S llama.cpp -B llama.cpp/build -DGGML_METAL=ON -DLLAMA_CURL=OFF
cmake --build llama.cpp/build --config Release -j 8
```

## Usage

### 1. Set up the environment (first time only)

```sh
./macOS_setup.sh
```

This runs `uv sync` (Python dependencies), removes `hf-xet`, and clones and
builds llama.cpp with Metal. The clone is skipped if llama.cpp already exists,
so the script is safe to re-run.

### 2. Log in to Hugging Face (for gated models)

Models like Gemma require license approval on the model page plus an access
token issued beforehand.

```sh
uv run hf auth login
uv run hf auth whoami
```

If your username is shown, you're good.

### 3. Quantize

```sh
./quantize.sh
```

By default this quantizes `google/gemma-4-E4B-it` to `Q4_K_M`.
Steps whose intermediate/final artifacts already exist are skipped.

For a different model or quantization type:

```sh
MODEL_ID=<org/model> QUANT=Q8_0 ./quantize.sh
```

Artifacts:

- `models/<model-name>/`: downloaded safetensors (~16GB)
- `gguf/<model-name>-BF16.gguf`: converted intermediate file (~14GB)
- `gguf/<model-name>-Q4_K_M.gguf`: quantized model (~5GB)

### 4. Verify (optional)

```sh
./llama.cpp/build/bin/llama-bench -m gguf/<model-name>-Q4_K_M.gguf -ngl 99 -p 128 -n 128
./llama.cpp/build/bin/llama-cli -m gguf/<model-name>-Q4_K_M.gguf -ngl 99 --temp 0.7 -c 4096
```

`-ngl 99` offloads as many layers as possible to the GPU.
