FROM node:22-alpine
RUN corepack enable
WORKDIR /repo
ENV NODE_ENV=production

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml* tsconfig.base.json ./
COPY packages/shared/package.json packages/shared/
COPY packages/worker/package.json packages/worker/
RUN pnpm install --frozen-lockfile || pnpm install

# 共享套件以 TS 原始碼直接引用，worker 透過 tsx 執行
COPY packages/shared packages/shared
COPY packages/worker packages/worker

CMD ["pnpm", "--filter", "@kinto/worker", "start"]
