FROM node:20-alpine AS base

FROM base AS builder

RUN apk add --no-cache gcompat
WORKDIR /app

COPY pnpm-lock.yaml ./
COPY package.json tsconfig.json src ./

# Adding logging to each step
RUN echo "Installing global pnpm" && \
    npm install -g pnpm && \
    echo "Installing dependencies" && \
    pnpm install --frozen-lockfile && \
    echo "Compiling TypeScript" && \
    pnpm tsc && \
    echo "Pruning dev dependencies" && \
    pnpm prune --prod

# Debug step to verify the dist directory exists
RUN echo "Verifying /app and /app/dist contents" && \
    ls -la /app && ls -la /app/dist

FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 hono

COPY --from=builder --chown=hono:nodejs /app/node_modules /app/node_modules
COPY --from=builder --chown=hono:nodejs /app/dist /app/dist
COPY --from=builder --chown=hono:nodejs /app/package.json /app/package.json
COPY --from=builder --chown=hono:nodejs /app/pnpm-lock.yaml /app/pnpm-lock.yaml

USER hono
EXPOSE 3100

CMD ["node", "/app/dist/index.js"]