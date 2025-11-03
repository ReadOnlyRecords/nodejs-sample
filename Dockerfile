FROM node:24 AS base

WORKDIR /app

# Copy package files and install dependencies as root
COPY package*.json ./
RUN npm ci --only=production

# Copy rest of the app
COPY . .

FROM base AS linter

WORKDIR /app

RUN npm run lint

FROM node:24

WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/package.json ./package.json
COPY --from=base /app/. .

# Create app user and group
RUN addgroup app && adduser -system --ingroup app app

# Install dependencies
RUN apt update && apt install ca-certificates curl \
  &&  rm -rf /var/cache/apk/*


# Switch to non-root user for runtime
USER app

EXPOSE 3000
CMD ["node", "app.js"]
