# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Create uploads directory
RUN mkdir -p uploads/videos

# Copy package files
COPY package*.json ./
COPY client/package*.json ./client/

# Install dependencies
RUN npm ci --only=production
RUN cd client && npm ci --only=production

# Copy source code
COPY . .

# Build the React frontend
RUN cd client && npm run build

# Set environment to production
ENV NODE_ENV=production

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/api/auth/verify || exit 1

# Start the application
CMD ["npm", "start"]
