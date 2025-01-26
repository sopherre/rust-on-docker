FROM rust:latest

WORKDIR /app

# システムパッケージの更新
RUN apt-get update

# make のインストール
RUN apt-get install -y --no-install-recommends make && rm -rf /var/lib/apt/lists/* 

COPY ./Cargo.toml ./Cargo.lock /app/

# Rust のフォーマットツール `rustfmt` をインストール
RUN rustup component add rustfmt

# `cargo-watch` をインストールし、ファイル変更を監視して自動ビルド・実行を可能にする
RUN cargo install cargo-watch

RUN cargo fetch || true

COPY ./src /app/src

RUN cargo build --release || true

CMD ["sleep", "infinity"]