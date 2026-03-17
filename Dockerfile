FROM node:24-slim AS builder
WORKDIR /app
COPY server.js .

FROM node:24-slim AS production
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=builder /app/server.js .

USER appuser
EXPOSE 3000
CMD ["node", "server.js"]
