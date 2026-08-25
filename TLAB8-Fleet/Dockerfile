# Hardened base image: alpine is minimal and secure
FROM node:alpine

WORKDIR /usr/src/app

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Run as non-root user (node user exists in node:alpine)
USER node

# Start the application
CMD ["node", "server.js"]
