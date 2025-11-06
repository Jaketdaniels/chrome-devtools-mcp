# Use Node.js 20 with Puppeteer (includes Chrome)
# Note: This image is amd64 only - will use emulation on Apple Silicon (ARM64)
FROM ghcr.io/puppeteer/puppeteer:24.1.0

# Set working directory
WORKDIR /app

# Copy all source files first (needed for prepare script)
COPY . .

# Install dependencies
RUN npm ci

# Build the project
RUN npm run build

# Set user to non-root for security
USER pptruser

# Expose MCP port (stdio transport doesn't need exposed ports, but good practice)
# MCP uses stdio by default when run with npx

# Run the MCP server
CMD ["node", "build/src/index.js"]
