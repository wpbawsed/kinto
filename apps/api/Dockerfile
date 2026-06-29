FROM node:22-alpine
RUN corepack enable
WORKDIR /repo
ENV NODE_ENV=production

# workspace manifests first for cached install
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml* tsconfig.base.json ./
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/
RUN pnpm install --frozen-lockfile || pnpm install

# 共享套件以 TS 原始碼直接引用，api 透過 tsx 執行
COPY packages/shared packages/shared
COPY apps/api apps/api

EXPOSE 3000
# 先跑 migrate 再啟動 server
CMD ["sh", "-c", "pnpm --filter @kinto/api db:migrate && pnpm --filter @kinto/api start"]
