FROM ubuntu:22.04 AS install-whisper
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y \
    git \
    build-essential \
    wget \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /whisper
RUN git clone https://github.com/ggml-org/whisper.cpp.git .
RUN git checkout v1.7.1
RUN make
WORKDIR /whisper/models
RUN sh ./download-ggml-model.sh base.en


FROM node:22-bookworm-slim AS base
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt update && apt install -y \
      git wget cmake ffmpeg curl make libsdl2-dev \
      libnss3 libdbus-1-3 libatk1.0-0 libgbm-dev \
      libasound2 libxrandr2 libxkbcommon-dev libxfixes3 \
      libxcomposite1 libxdamage1 libatk-bridge2.0-0 \
      libpango-1.0-0 libcairo2 libcups2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# pnpm setup
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable

# install dependencies (DEV = full install)
COPY package.json pnpm-lock.yaml* /app/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install

# copy source
COPY src /app/src
COPY static /app/static
COPY tsconfig.json tsconfig.build.json vite.config.ts /app/

# build the project
RUN pnpm run build

# whisper
COPY --from=install-whisper /whisper /app/data/libs/whisper

# env
ENV DATA_DIR_PATH=/app/data
ENV DOCKER=true
ENV WHISPER_MODEL=base.en
ENV DEV=true

# expose port
EXPOSE 3123

# 🚀 DEV MODE
CMD ["npx", "remotion", "preview", "--port", "3123"]