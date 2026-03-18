# Junior Platform Engineer Task
![Build Status](https://github.com/matthewbbarthet/mbb_jpe_task_hornet/actions/workflows/docker-publish.yml/badge.svg)

Node.js Hello World application served behind an Nginx reverse proxy containerised with docker with CI/CD to be automatically built and published to Docker Hub via GitHub Actions


## Stack

| Layer       | Technology                 |
|-------------|----------------------------|
| Application | Node.js 24                 |
| Web server  | Nginx (reverse proxy)      |
| Container   | Docker (multi-stage build) |
| CI/CD       | GitHub Actions             |
| Registry    | Docker Hub                 |


## Endpoints

| Endpoint      | Description                                       |
|---------------|---------------------------------------------------|
| `GET /`       | Returns `Hello World`                             |
| `GET /health` | Returns `{ "status": "ok", "uptime": <seconds> }` |


## Project Structure

server.js # Node.js HTTP server
Dockerfile # Multi-stage production image
docker-compose.yml # Local development setup
.dockerignore # Excludes unnecessary files from build context
nginx/
  nginx.conf # Reverse proxy config with security headers
.github/
  workflows/
    docker-publish.yml #CI/CD pipeline


## Architecture
Browse -> port 80 -> Nginx -> port 3000 -> Node.js Hello World app

Nginx acts as a reverse proxy, meaning Nginx receives all requests and selectively forwards them to the nodejs application. In this way, the Node.js container is never directly exposed to the host machine, and Nginx acts as a controlled entry point handling connection management and security headers before any request reaches the application.

## CI/CD Pipeline
The GitHub Actions workflow .github/workflows/docker-publish.yml triggers on every push to any branch and performs the following steps:
1. Checkout - clones the repository onto the runner
2. Set up Docker Buildx - enables builds and layer caching
3. Log in to Docker Hub - authenticates using repo secrets
4. Extract short SHA - generates short commit hash for image tagging
5. Build and push - builds the production image and publishes to Docker Hub
The image is published with two tags:
- :latest - always points to the most recent build
- :short-sha - immutable tag tied to a specific commit for rollback

### Note
I tried implementing trivy security scan but I could not get it to work. Apparently it has been very unreliable since March 1st of this year when it was compromised by an autonomous AI

## Docker Image
The image uses a multi-stage build to keep the final image lean
- builder stage - copies source files
- production stage - runs as a non-root user with only the files needed

```bash
docker run -p 3000:3000 matthewbbarthet/mbb_jpe_task_hornet:latest
```

## Security Measures
- Non-root container user - app runs as appuser not root
- Nginx security headers - X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy
- server_tokens off - hides nginx version from response headers
- Docker HEALTHCHECK - container health monitored via the /health endpoint
- Graceful shutdown - SIGTERM handler ensures clean container stop
- .dockerignore - reduces build context and attack surface
