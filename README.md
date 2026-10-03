# quantization

LLM の量子化・GGUF 変換用リポジトリの初期土台。

## 概要

- 目的: Hugging Face モデルを取得し、量子化して `gguf/` に出力する（想定）。
- 現状: 未実装。`main.py` は Hello 表示のみ、`gguf/` と `models/` は空。

## 仕組み（想定）

`pyproject.toml` の依存関係からの推測:

- `transformers` + `huggingface-hub`: モデル取得・読み込み
- `torch`: 量子化処理
- `sentencepiece` + `protobuf`: トークナイザ処理
- `gguf`: GGUF 書き出し

## 使い方

```sh
uv sync
uv run main.py
```
