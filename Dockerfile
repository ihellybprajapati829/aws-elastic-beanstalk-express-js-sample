# Dockerfile
# Containerises the Node.js application for the Jenkins pipeline to build and push.

# Multi-stage build: install dependencies in a build stage using node:16, then copy only the result into a clean runtime stage. 
# This removes npm - and its bundled CVEs that can't be patched while staying Node-16-compatible - from the final image entirely, since the running app only needs node, not npm. 

FROM node:16-alpine AS builder 
WORKDIR /app 

# Copy the manifest files first so Docker can cache the npm install layer - it only re-runs if package.json/package-lock.json actually change, not on every source code edit.
COPY package*.json ./ 
RUN npm install --production 
# Copy of the application source
COPY . . 

FROM node:16-alpine 
WORKDIR /app 
# Patch known OS-level CVEs in musl/openssl to their fixed versions 
RUN apk update && apk upgrade --no-cache 

# Copy of the application source from builder
COPY --from=builder /app ./ 

# Remove npm and npx from the final image - the app only needs node to # run, and stripping npm removes its bundled dependency CVEs entirely 
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx 

EXPOSE 8080 
CMD ["node", "app.js"]

