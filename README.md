# DWP Senior DevOps Engineer: Containerisation Assessment

## Overview

This repository contains my solution to Part 1 of the DWP Senior DevOps Engineer technical assessment.

The objective was to refactor the supplied Dockerfile to improve container security, build efficiency and maintainability while preserving the existing Python Flask application.

The application source code and dependencies have not been modified. Gunicorn remains the application server.

## Container Improvements

The original Dockerfile has been refactored with the following improvements:

- **Smaller base image:** Uses `python:3.12-slim` instead of the full Python image to reduce the container's footprint.
- **Reduced unnecessary packages:** Removes build tools and utilities that are not required to run the application.
- **Non-root execution:** Creates a dedicated `appuser` and `appgroup`, reducing the privileges available to the application.
- **Improved layer caching:** Copies `requirements.txt` before application source files so that application changes do not unnecessarily invalidate the dependency installation layer.
- **Selective file copying:** Copies only the files required by the application rather than the entire repository.
- **Build-context optimisation:** Adds `.dockerignore` to exclude Git metadata, development files, caches and local environment files.
- **Python runtime configuration:** Disables bytecode generation, enables unbuffered logging and prevents pip from retaining its download cache.
- **Gunicorn:** Preserves the original application server, binding to port 8080 with two workers.

A single-stage Dockerfile was retained because the application has a small dependency set and does not require a separate compilation stage.

## Build Locally

From the repository root:

```bash
docker build -t dwp-greeting-container:v1.0.0 .
```

## Run the Container

```bash
docker run -d \
  --name dwp-greeting \
  -p 8080:8080 \
  -e GREETING="Hello from DWP!" \
  dwp-greeting-container:v1.0.0
```

## Verify the Application

The application exposes three HTTP endpoints:

| Endpoint | Purpose |
|---|---|
| `GET /` | Returns the greeting and container hostname |
| `GET /healthz` | Returns application health status |
| `GET /info` | Returns basic runtime information |

Test the endpoints:

```bash
curl http://localhost:8080/
curl http://localhost:8080/healthz
curl http://localhost:8080/info
```

The `/healthz` endpoint can also be used for Kubernetes readiness and liveness probes during the deployment stage.

## Published Container Image

The image is publicly available on GitHub Container Registry:

```text
ghcr.io/oluwatossin/dwp-greeting-container:v1.0.0
```

Pull and run the published image:

```bash
docker pull ghcr.io/oluwatossin/dwp-greeting-container:v1.0.0

docker run -d \
  --name dwp-greeting \
  -p 8080:8080 \
  ghcr.io/oluwatossin/dwp-greeting-container:v1.0.0
```

The published image supports both `linux/amd64` and `linux/arm64`.

## Validation

The container was tested locally on both AMD64 and ARM64 architectures.

Validation included:

- Successful image builds and container startup.
- Successful HTTP responses from `/`, `/healthz` and `/info`.
- Verification that Gunicorn starts with two workers.
- Confirmation that the application runs as a non-root user.
- Python dependency consistency checks.
- Successful anonymous pull from GHCR.
- HTTP verification of the published GHCR image.


## Cleanup

```bash
docker rm -f dwp-greeting
```
