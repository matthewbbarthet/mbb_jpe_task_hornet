FROM node:24-slim AS builder
WORKDIR /app
COPY server.js .

FROM node:24-slim AS production
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=builder /app/server.js .

USER appuser
EXPOSE 3000

# health check using node instead of curl since node:24-slim image does not have curl
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD ["node", "-e", "require('http').get('http://localhost:3000/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"] 

CMD ["node", "server.js"]
