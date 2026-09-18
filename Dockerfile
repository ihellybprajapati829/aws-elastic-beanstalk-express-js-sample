# Dockerfile
# Containerises the Node.js application for the Jenkins pipeline to build and push. 

FROM node:16-alpine

WORKDIR /app

# Security Gate Failure - resolved
# Patch for OS-level CVEs in musl/openssl to their fixed versions 
RUN apk update && apk upgrade --no-cache 
# Upgrade npm itself - carry known # CVEs. It's the npm CLI tool bundled in the base image. Installing a newer npm compatible with Node 16. 
RUN npm install -g npm@9

# Copy the manifest files first so Docker can cache the npm install layer - it only re-runs if package.json/package-lock.json actually change, not on every source code edit.
COPY package*.json ./
RUN npm install --production

# Copy of the application source
COPY . .

EXPOSE 8080

CMD ["npm", "start"]
