# quantization

LLM の量子化・GGUF 変換用リポジトリの初期土台。

## 概要

- 目的: Hugging Face モデルを取得し、量子化して `gguf/` に出力する。
- 構成: `macOS_setup.sh`（環境構築）、`quantize.sh`（DL→変換→量子化）。

## 仕組み（想定）

`pyproject.toml` の依存関係からの推測:

- `transformers` + `huggingface-hub`: モデル取得・読み込み
- `torch`: 量子化処理
- `sentencepiece` + `protobuf`: トークナイザ処理
- `gguf`: GGUF 書き出し

## Requirements

- macOS 前提
- llama.cpp（Metal ビルド）: `./macOS_setup.sh` が clone〜ビルドまで行う

```sh
./macOS_setup.sh
```

手動で行う場合:

```sh
git clone https://github.com/ggml-org/llama.cpp.git
cmake -S llama.cpp -B llama.cpp/build -DGGML_METAL=ON -DLLAMA_CURL=OFF
cmake --build llama.cpp/build --config Release -j 8
```

## 使い方

### 1. 環境構築（初回のみ）

```sh
./macOS_setup.sh
```

`uv sync`（Python 依存関係）、`hf-xet` 除去、llama.cpp の clone〜Metal ビルドを行う。
llama.cpp が既にあれば clone はスキップされるので再実行可。

### 2. Hugging Face にログイン（ gated モデルの場合）

Gemma 等ライセンス承認が必要なモデルは、事前にモデルページでライセンス承認＋
アクセストークン発行が必要。

```sh
uv run hf auth login
uv run hf auth whoami
```

ユーザー名が表示されれば OK。

### 3. 量子化する

```sh
./quantize.sh
```

既定では `google/gemma-4-E4B-it` を `Q4_K_M` に量子化する。
中間・最終成果物が既にあれば各工程はスキップされる。

別モデル・別方式にする場合:

```sh
MODEL_ID=<org/model> QUANT=Q8_0 ./quantize.sh
```

生成物:

- `models/<モデル名>/`: ダウンロードした safetensors（約16GB）
- `gguf/<モデル名>-BF16.gguf`: 変換後の中間ファイル（約14GB）
- `gguf/<モデル名>-Q4_K_M.gguf`: 量子化済み（約5GB）

### 4. 動作確認（任意）

```sh
./llama.cpp/build/bin/llama-bench -m gguf/<モデル名>-Q4_K_M.gguf -ngl 99 -p 128 -n 128
./llama.cpp/build/bin/llama-cli -m gguf/<モデル名>-Q4_K_M.gguf -ngl 99 --temp 0.7 -c 4096
```

`-ngl 99` はできるだけ多くのレイヤーを GPU 側に載せる指定。
