# Multi-stage build for chrome-devtools-mcp
# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy source code
COPY . .

# Install dependencies and build
RUN npm ci && npm run build

# Runtime stage - includes Chromium browser
FROM node:22-alpine

WORKDIR /app

# Install Chromium and required dependencies
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    && rm -rf /var/cache/apk/*

# Copy package files and scripts (needed for prepare script)
COPY package*.json ./
COPY scripts ./scripts

# Install production dependencies only
RUN npm ci --omit=dev && npm cache clean --force

# Copy built code from builder stage
COPY --from=builder /app/build ./build

# Tell Puppeteer to use installed Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Create non-root user
RUN addgroup -g 10042 pptruser && \
    adduser -D -u 10042 -G pptruser pptruser && \
    chown -R pptruser:pptruser /app

USER pptruser

CMD ["node", "build/src/index.js"]
