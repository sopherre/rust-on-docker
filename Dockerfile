# Rust の公式イメージ（最新バージョン）をベースとして使用
FROM rust:latest

# コンテナ内の作業ディレクトリを `/app` に設定
WORKDIR /app

# 必要なシステムパッケージの更新
RUN apt-get update

# ロケールパッケージのインストール
RUN apt-get install -y --no-install-recommends locales

# 日本語フォントのインストール
RUN apt-get install -y --no-install-recommends fonts-noto-cjk

# 日本語入力システム Mozc のインストール
RUN apt-get install -y --no-install-recommends fcitx-mozc

# make のインストール
RUN apt-get install -y --no-install-recommends make

# キャッシュ削除でイメージサイズを最適化
RUN rm -rf /var/lib/apt/lists/*

# 日本語ロケールの設定
RUN locale-gen ja_JP.UTF-8 && \
  echo 'LANG=ja_JP.UTF-8' > /etc/default/locale && \
  echo 'LC_ALL=ja_JP.UTF-8' >> /etc/default/locale && \
  echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales

# 環境変数としてロケールを設定
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# Rust のフォーマットツール `rustfmt` のインストール
RUN rustup component add rustfmt

# `cargo-watch` をインストールし、ファイル変更を監視して自動ビルド・実行を可能にする
RUN cargo install cargo-watch

# Rust の依存関係を事前にフェッチ（キャッシュ効率を向上）
# このステップで依存関係を分離することで、コードの変更によるビルドの影響を軽減
COPY ./Cargo.toml ./Cargo.lock /app/
RUN cargo fetch || true

# プロジェクトのソースコードをコンテナ内にコピー
COPY ./src /app/src

# プロジェクトのビルド（エラーが発生しても続行）
RUN cargo build --release || true

# デフォルトのコマンドを設定
# コンテナ起動後は無限にスリープし、コンテナを終了させない（開発時の利便性向上）
CMD ["sleep", "infinity"]