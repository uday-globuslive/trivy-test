# Sample Dockerfile for testing Trivy scan
FROM node:14-alpine

WORKDIR /app

# Install some sample packages for scanning
COPY package.json ./
RUN npm install

COPY . .

CMD ["node", "app.js"]
