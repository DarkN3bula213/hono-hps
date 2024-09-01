FROM node:20-alpine AS base

FROM base AS builder

RUN apk add --no-cache gcompat
WORKDIR /app

COPY pnpm-lock.yaml ./
COPY package.json tsconfig.json src ./

RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile && \
    pnpm tsc && \
    pnpm prune --prod



# Debug step to verify the dist directory exists
RUN ls -la /app && ls -la /app/dist
FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 hono

COPY --from=builder --chown=hono:nodejs /app/node_modules /app/node_modules
COPY --from=builder --chown=hono:nodejs /app/dist /app/dist
COPY --from=builder --chown=hono:nodejs /app/package.json /app/package.json
COPY --from=builder --chown=hono:nodejs /app/pnpm-lock.yaml /app/pnpm-lock.yaml

USER hono
EXPOSE 3000

CMD ["node", "/app/dist/index.js"]