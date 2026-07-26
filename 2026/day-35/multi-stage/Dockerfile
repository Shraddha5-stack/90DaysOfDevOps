FROM node:22 AS builder

WORKDIR /app
COPY app/ .

FROM node:22-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app .

USER appuser

CMD ["node", "app.js"]
