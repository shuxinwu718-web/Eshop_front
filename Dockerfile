# ---- Build Stage ----
FROM node:22-alpine AS build
WORKDIR /app

# 固定 pnpm 大版本（lockfile v9，兼容 pnpm 9/10）
RUN npm install -g pnpm@10

# 先装依赖（利用层缓存）
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
RUN pnpm install --frozen-lockfile

# 再拷源码构建（读取 .env.production）
COPY . .
RUN pnpm build

# ---- Runtime Stage ----
FROM nginx:1.27-alpine
ENV TZ=Asia/Shanghai
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
